# @summary configure Apache HTTPd modules
#
# @param enable_php
#   Enable PHP modules
#
# @param enable_auth
#   Enable auth modules
#
# @param enable_php
#   Enable PHP modules
#
# @example
#   include profile_website::modules
class profile_website::modules (
  Boolean $enable_auth,
  Boolean $enable_php,
) {

  if $enable_auth {
    include profile_website::modules::auth
  }
  if $enable_php {
    include profile_website::modules::php
  }

  # OTHER MODULES
  # ENABLE APACHE MODULES DEFINED IN HIERA
  $my_apache_modules = lookup( 'apache::modules' )

  $my_apache_modules.each | $k, $v | {
    class { "apache::mod::${k}": * => $v }
  }

}
