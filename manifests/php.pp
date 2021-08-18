# @summary Install and configure PHP
#
# @param ini_file
#   Full path to default ini_file where PHP settings are set
#
# @param ini_settings
#   Key value pairs of desired PHP settings
#
# @example
#   include profile_website::php
class profile_website::php (
  String               $ini_file,
  Hash[String, String] $ini_settings,
) {

  if ($facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] >= '8') {
    # USE 7.4 VERSION OF YUM/DNF PHP MODULE
    $dnf_php_command = 'dnf -y module reset php && dnf -y module enable php:7.4'
    exec { 'ensure_dnf_php_module_7.4':
      path    => ['/bin', '/usr/bin', '/usr/sbin'],
      unless  => 'dnf module list php | grep 7.4 | egrep -i \'7.4 \[[e|d]\]\'',
      command => $dnf_php_command,
    }
  }

  include ::apache::mod::php
  ## IF IN FUTURE WE SET PARAMETERS
  #ensure_resource( 'class', '::apache::mod::php', lookup('apache::mod::php') )

  File_line {
    ensure => 'present',
  }

  file { $ini_file:
    ensure => 'present',
    mode   => '0644',
  }
  if ($ini_settings)
  {
    $ini_settings.each | $k, $v | {
      ## NOTE THAT THIS DOES NOT CLEAN UP HISTORICAL SETTINGS THAT ARE REMOVED
      file_line { "${ini_file} ${k} = ${v}":
        path    => $ini_file,
        replace => true,
        line    => "${k} = ${v}",
        match   => "${k}.*",
        notify  => Class['apache::service']
      }
    }
  }

  file_line { 'PHP disable expose_php':
    line   => 'expose_php = Off',
    match  => '^expose_php = .*$',
    path   => $ini_file,
    notify => Class['apache::service']
  }

}
