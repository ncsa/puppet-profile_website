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
    ( $default_ssl_cert in $facts['ssl_certificates'] and $default_ssl_key in $facts['ssl_keys'] )
    or
    ( ! $profile_website::ssl::enable_letsencrypt and ! empty($profile_website::ssl::certificate_files) )
  ) {
    # DEFAULT SSL FILES EXIST, SO USE DEFAULT VHOST
    ensure_resources('apache::vhost', lookup('apache::vhost', {}) )
  }
  elsif ( $profile_website::ssl::enable_letsencrypt ) {
    # DEFAULT SSL FILES DO NOT EXIST,
    # SO USE TEMPORARY VHOST CONFIG THAT ALLOWS LETSENCRYPT TO GET SETUP
    #   POSSIBLE ALTERNATE SOLUTION: TEMPORARILY SET apache::default_vhost = true

    ## NOTIFY THAT SSL FILES ARE MISSING SO USING TEMPORARY VHOST
    $notify_text = @("EOT"/)
      Default SSL certificate and/or key files are currently missing on this host.
      Using an alternate apache::vhost configuration without SSL to temporary allow LetsEncrypt to create the SSL certificate.
      You must run Puppet agent once more to use the LetsEncypt certificates that are being created.
      | EOT
    notify { $notify_text:
      withpath => true,
      loglevel => 'warning',
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
    $ssl_vhost_name = String("${facts['networking']['fqdn']}-ssl")
    $servername = $vhost[$ssl_vhost_name]['servername']
    $serveraliases = $vhost[$ssl_vhost_name]['serveraliases']
    $docroot = $vhost[$ssl_vhost_name]['docroot']

    apache::vhost { "${facts['networking']['fqdn']}-temp-nossl":
      port            => 80,
      servername      => $servername,
      serveraliases   => $serveraliases,
      access_log_pipe => "|/bin/sh -c '/usr/bin/tee \
        -a /var/log/httpd/${facts['networking']['fqdn']}-nossl_access.log' \
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
        -a /var/log/httpd/${facts['networking']['fqdn']}-nossl_error.log' \
        |/bin/sh -c '/usr/bin/logger -t httpd -p local6.err'",
      before          => Class['letsencrypt'],
    }
  }
  elsif ( ! $profile_website::ssl::enable_letsencrypt and ! empty($profile_website::ssl::certificate_files) ) {
    # NOT USING LETS ENCYRPT BUT STATIC CERTS AREN'T YET KNOWN BY CUSTOM FACTS YET
    # THIS IS UNLIKELY TO HAPPEN AS PREVIOUS elsif SHOULD WORK AROUND THIS
    $notify_text = @("EOT"/)
      Default SSL certificate and/or key files are currently missing on this host.
      Presumably this Puppet agent run will install the custom certificates,
      but they are not yet known by the custom Puppet fact that looks for the certificates.
      You must run Puppet agent once more to use the custom certificates that are being created.
      | EOT
    notify { $notify_text:
      withpath => true,
      loglevel => 'warning',
    }
  }
  else {
    ## UNKNOWN ERROR
    $notify_text = @("EOT"/)
      Unknown Error figuring out SSL certificate and/or key files.
      | EOT
    notify { $notify_text:
      withpath => true,
    }
  }
}
