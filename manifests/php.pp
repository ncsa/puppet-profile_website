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
# @param fpm_proxy
#   php-fpm address Apache hands .php requests to when handler is 'fpm'
#   (matches the default puppet-php 'www' pool)
#
# @param handler
#   How Apache runs PHP: 'mod_php' (libphp loaded into httpd) or 'fpm'
#   (php-fpm via mod_proxy_fcgi; required on RHEL 9, which has no mod_php)
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
  String               $fpm_proxy,
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
      # HAND .php REQUESTS TO php-fpm INSTEAD OF LOADING libphp INTO httpd
      # mod_dir PROVIDES DirectoryIndex (ITS DEFAULT LIST INCLUDES index.php)
      include apache::mod::dir
      include apache::mod::proxy_fcgi
      apache::custom_config { 'php-fpm':
        content => @("EOT"),
          # This file is managed by Puppet.
          <FilesMatch \.php$>
            SetHandler "proxy:${fpm_proxy}"
          </FilesMatch>
          | EOT
        require => Class['apache::mod::dir', 'apache::mod::proxy_fcgi'],
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
