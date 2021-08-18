# @summary configure an Apache HTTPd website
#
# A description of what this class does
#
# @example
#   include profile_website
class profile_website (
) {

  include profile_website::firewall
  include profile_website::modules
  include profile_website::ssl

  # Include Apache
  class { 'apache':
    default_vhost => false,
  }

  # CREATE A HASH FROM HIERA DATA WITH THE VHOSTS
  $my_apache_vhosts = hiera('apache::vhost', {})

  # WITH CREATE RESOURCE CONVERTS A HASH INTO A SET OF RESOURCES
  create_resources('apache::vhost', $my_apache_vhosts)

}
