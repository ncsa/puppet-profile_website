# @summary Configure default httpd authentication modules
#
# @example
#   include profile_website::modules::auth
class profile_website::modules::auth {

  include ::profile::ldap
  class { 'apache::mod::ldap':
  }

  ## ADD FOLLOWING AUTH MODULES
  ## - kerberos/gssapi
  ## - openidc

  ## ENSURE /etc/httpd/conf.d/krb5.keytab
  ## CAN FOLLOWING BE AUTOMATED IF HOST ALREADY HAS A HOSTKEY?
  ## #  String $keytab,  ## BASE64 ENCODING OF krb5.keytab FILE
  ## #  file { '/etc/httpd/conf.d/krb5.keytab':
  ## #    ensure  => present,
  ## #    owner   => root,
  ## #    group   => apache,
  ## #    mode    => '0640',
  ## #    content => base64('decode', $keytab),
  ## #  }

}
