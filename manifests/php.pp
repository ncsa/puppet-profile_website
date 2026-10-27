# @summary Install and configure PHP
#
# @param auto_prepend_file
#   Full path to default auto_prepend_file
#
# @param auto_prepend_file_content
#   Contents of auto_prepend_file
#
# @param enable
#   Whether to enable PHP for this website
#
# @param handler
#   How Apache runs PHP: 'mod_php' (libphp loaded into httpd) or 'fpm'
#   (php-fpm via mod_proxy_fcgi using the php-fpm RPM's conf.d/php.conf;
#   required on RHEL 9, which has no mod_php). With 'fpm', leave the
#   php-fpm 'www' pool at the RPM default (php::fpm_pools: {}) so it
#   listens on the socket php.conf points at.
#
# @param ini_file
#   Full path to default ini_file where PHP settings are set
#
# @param version
#   Version of PHP to install/enable via DNF module (RHEL >= 8)
#
# @example
#   include profile_website::php
class profile_website::php (
  String               $auto_prepend_file,
  String               $auto_prepend_file_content,
  Boolean              $enable,
  Enum['mod_php', 'fpm'] $handler,
  String               $ini_file,
  String               $version,
) {
  if $enable {
    if ($facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] >= '8') {
      # SELECT SPECIFIC VERSION OF PHP VIA DNF MODULE SETTINGS
      $dnf_php_command = "dnf -y module reset php && dnf -y module enable php:${version}"
      exec { "ensure_dnf_php_module_${version}":
        path    => ['/bin', '/usr/bin', '/usr/sbin'],
        unless  => "dnf module list php | grep ${version} | egrep -i \'${version} \\[[e|d]\\]\'",
        command => $dnf_php_command,
      }
    }

    if $handler == 'fpm' {
      # USE THE php-fpm RPM'S OWN APACHE CONFIG (conf.d/php.conf), WHICH HANDS
      # .php REQUESTS TO php-fpm; LOAD THE MODULES IT USES
      include apache::mod::dir         # DirectoryIndex
      include apache::mod::proxy_fcgi  # SetHandler "proxy:unix:...|fcgi://..."
      include apache::mod::setenvif    # SetEnvIfNoCase Authorization

      # DECLARING THE FILE KEEPS apache::purge_configs FROM DELETING IT;
      # NO ensure/content, SO PUPPET NEVER CREATES OR CHANGES IT
      file { "${apache::confd_dir}/php.conf":
        require => Class['php'],
      }
    } else {
      include apache::mod::php
    }
    include php

    file { $auto_prepend_file:
      ensure  => file,
      content => $auto_prepend_file_content,
      mode    => '0644',
      owner   => root,
      group   => root,
      notify  => Class['apache::service'],
    }

    file { $ini_file:
      ensure => 'file',
      mode   => '0644',
    }

    # PHP MODULE WASN'T UPDATING THE VALUES IN /etc/php.ini AS EXPECTED
    $php::settings.each | $setting, $value | {
      ini_setting { "${ini_file} ${setting} = ${value}":
        ensure  => present,
        path    => $ini_file,
        section => 'PHP',
        setting => $setting,
        value   => $value,
        notify  => Service['php-fpm'],
      }
    }
  }
}
