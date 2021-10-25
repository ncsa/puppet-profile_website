# @summary Configure an Apache HTTPd website
#
# @example
#   include profile_website
class profile_website (
) {

  include ::apache
  include ::apache::mod::alias
  include ::apache::mod::autoindex
  include ::apache::mod::ldap
  ## IF IN FUTURE WE SET PARAMETERS
  #ensure_resource( 'class', '::apache::mod::ldap', lookup('apache::mod::ldap') )
  #include ::apache::mod::proxy
  ensure_resource( 'class', '::apache::mod::proxy', lookup('apache::mod::proxy') )
  include ::apache::mod::proxy_http
  include ::apache::mod::proxy_wstunnel

#  include ::apache::mod::auth_openidc
  include profile_website::firewall
  include profile_website::kerberos
  include profile_website::monitoring
  include profile_website::php
  include profile_website::ssl
  include profile_website::vhost

}
