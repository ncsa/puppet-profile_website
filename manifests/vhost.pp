# @summary Ensure apache::vhost configured
#
# @example
#   include profile_website::vhost
class profile_website::vhost {

  # THIS IS A BIT TRICKY IN THAT ::letsencrypt NEEDS A WORKING APACHE CONFIG
  # IN ORDER TO CREATE THE INITIAL SSL CERTIFICATE
  # SO WE MAY NEED TO OVERRIDE THE apache::vhost LOOKUP PARAMETERS
  # IF THE DEFINED SSL CERTIFICATES DO NOT YET EXIST

  $default_ssl_cert = lookup('apache::default_ssl_cert', String)
  $default_ssl_key = lookup('apache::default_ssl_key', String)

  if ( empty($default_ssl_cert) or empty($default_ssl_key) ) {
    ## NOTIFY THAT DEFAULT SSL PARAMETERS FOR FILES ARE MISSING
    $notify_text = @("EOT"/)
      Default SSL configs for certificate and/or key files are missing.
      The following parameters must not be empty:
        - apache::default_ssl_cert
        - apache::default_ssl_key
      | EOT
    notify { $notify_text:
      withpath => true,
    }
  }
  elsif (
    $default_ssl_cert in $facts['ssl_certificates']
    and $default_ssl_key in $facts['ssl_keys']
  ) {
    # DEFAULT SSL FILES EXIST, SO USE DEFAULT VHOST
    ensure_resources('apache::vhost', lookup('apache::vhost', {}) )
  } else {
    # DEFAULT SSL FILES DO NOT EXIST,
    # SO USE TEMPORARY VHOST CONFIG THAT ALLOWS LETSENCRYPT TO GET SETUP
    #   POSSIBLE ALTERNATE SOLUTION: TEMPORARILY SET apache::default_vhost = true

    ## NOTIFY THAT SSL FILES ARE MISSING SO USING TEMPORARY VHOST
    $notify_text = @("EOT"/)
      Default SSL certificate and/or key files are currently missing on this host.
      Using an alternate apache::vhost configuration without SSL to temporary allow LetsEncrypt (if enabled) to create the SSL certificate.
      | EOT
    notify { $notify_text:
      withpath => true,
    }

    # THE FOLLOWING WILL BE REMOVED ONCE LETS ENCRYPT OBTAINS ITS FIRST CERTIFICATE
    firewall { '400 temporarily allow HTTP on tcp port 80 for letsencrypt':
      dport  => '80',
      proto  => tcp,
      source => '0.0.0.0/0',
      action => accept,
      before => Class['letsencrypt'],
    }

    $vhost = lookup('apache::vhost', Hash)
    $ssl_vhost_name = String("${facts['fqdn']}-ssl")
    $servername = $vhost[$ssl_vhost_name]['servername']
    $serveraliases = $vhost[$ssl_vhost_name]['serveraliases']
    $docroot = $vhost[$ssl_vhost_name]['docroot']

    apache::vhost { "${facts['fqdn']}-temp-nossl":
      port            => 80,
      servername      => $servername,
      serveraliases   => $serveraliases,
      access_log_pipe => "|/bin/sh -c '/usr/bin/tee \
        -a /var/log/httpd/${facts['fqdn']}-nossl_access.log' \
        |/bin/sh -c '/usr/bin/logger -t httpd -p local6.notice'",
      directories     => [
        { 'path'    => $docroot,
          'require' => [
            'expr ( %{HTTP_USER_AGENT} =~ /validation server/)',
            'expr ( %{HTTP_USER_AGENT} =~ /www.letsencrypt.org/)',
          ],
        },
      ],
      docroot         => $docroot,
      error_log_pipe  => "|/bin/sh -c '/usr/bin/tee \
        -a /var/log/httpd/${facts['fqdn']}-nossl_error.log' \
        |/bin/sh -c '/usr/bin/logger -t httpd -p local6.err'",
      before          => Class['letsencrypt'],
    }
  }

}
