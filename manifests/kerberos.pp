# @summary Manage Kerberos HTTP Principal
#
# @param enable
#   Whether or not kerberos keytab is enabled
#
# @param http_keytab_file
#   Full path to keytab file for http principal
#
# @example
#   include profile_website::kerberos
class profile_website::kerberos (
  Boolean $enable,
  String $http_keytab_file,
) {
  if $enable {
    include apache::mod::auth_gssapi
    ## IF IN FUTURE WE SET PARAMETERS
    #ensure_resource( 'class', '::apache::mod::auth_gssapi', lookup('apache::mod::auth_gssapi') )

    ## SEE https://wiki.ncsa.illinois.edu/display/SecOps/Apache+-+Kerberos+Authentication+and+LDAP+Authorization

    # SHOULD WE REKEY THESE OCCASIONALLY ?

    # KRB COMMAND STRINGS
    $kadmin_query = "kadmin -k -p host/${facts['networking']['fqdn']} -q"
    $http_principal = "HTTP/${facts['networking']['fqdn']}"

    exec { 'ensure_http_principal':
      path    => ['/bin', '/usr/bin', '/usr/sbin'],
      unless  => [
        "${kadmin_query} \"getprinc ${http_principal}\" | grep -i HTTP",
      ],
      command => "${kadmin_query} \"addprinc -randkey ${http_principal}\" && rm -f \"${http_keytab_file}\"",
      notify  => Exec['ensure_http_keytab'],
    }

    exec { 'ensure_http_keytab':
      path    => ['/bin', '/usr/bin', '/usr/sbin'],
      unless  => [
        "klist -ek ${http_keytab_file} | grep -i Principal",
      ],
      command => "${kadmin_query} \"ktadd -e aes256-cts -k ${http_keytab_file} ${http_principal}\"",
      require => Exec['ensure_http_principal'],
    }
  }
}
