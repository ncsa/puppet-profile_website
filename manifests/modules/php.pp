# @summary Install and configure PHP
#
# @ini_file
#   full path to php.ini file
#
# @param packages
#   list of packages necessary for PHP installation
#
# @param yumrepo
#   yum repository for installing PHP
#
# @example
#   include profile_website::modules::php
class profile_website::modules::php (
  String              $ini_file,
  Array[String[1], 1] $packages,
  String              $yumrepo,
) {

  # PROBABLY SHOULD BE REPLACED BY AN EXISTING PUPPET MODULE
  # https://forge.puppet.com/modules/bodgit/php
  # include ::php

  # REBASE THIS TO WORK ACROSS RHEL/CENTOS VERSIONS
  # LIKELY AN OPTIONAL REPO VIA A HASH
#  ensure_resource('yumrepo', 'centos-sclo-rh', {
#    'ensure'     => 'present',
#    'baseurl'    => $scl_yumrepo_baseurl,
#    'descr'      => 'CentOS-7 - SCLo rh',
#    'enabled'    => 1,
#    'gpgcheck'   => 0,
#    'gpgkey'     => 'absent',
#    'mirrorlist' => 'absent',
#  })
#
#  exec { 'clean centos-sclo-rh yum repo':
#    subscribe   => Yumrepo['centos-sclo-rh'],
#    refreshonly => true,
#    path        => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
#    command     => 'yum clean all --disablerepo=* --enablerepo=centos-sclo-rh',
#    require     => [
#      Yumrepo['centos-sclo-rh'],
#    ],
#  }
#
#  Package {
#    require => Yumrepo['centos-sclo-rh'],
#  }

  ensure_packages( $packages, {'ensure' => 'present'} )

  File_line {
    ensure => 'present',
  }
  file_line { 'PHP disable expose_php':
    line   => 'expose_php = Off',
    match  => '^expose_php = .*$',
    path   => $ini_file,
    notify => Class['apache::service']
  }

}
