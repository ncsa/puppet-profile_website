# @summary Configure SSL certificates for apache httpd
#
# @param certificate_files
#   Certificate files and contents for manually configured certificates
#
# @param enable_letsencrypt
#   Enable Let’s Encrypt for ssl certificate management
#
# @example
#   include profile_website::ssl
class profile_website::ssl (
  Hash[String,String] $certificate_files,
  Boolean             $enable_letsencrypt,
) {

  ensure_resource( 'class', '::apache::mod::ssl', lookup('apache::mod::ssl') )

  if $enable_letsencrypt {
    include ::letsencrypt

    ## PULL apache::vhost DATA FOR $facts['fqdn']
    $vhost = lookup('apache::vhost', Hash)
    $vhost_name = String("${facts['fqdn']}-ssl")
    $servername = $vhost[$vhost_name]['servername']
    $serveraliases = $vhost[$vhost_name]['serveraliases']
    $domains = unique( sort( [ $facts['fqdn'], $servername ] + $serveraliases ))
    $docroot = $vhost[$vhost_name]['docroot']
    letsencrypt::certonly { $facts['fqdn']:
      domains       => $domains,
      plugin        => 'webroot',
      webroot_paths => [
        $docroot,
      ],
      require       => [
        Class['apache::service'],
        Class['profile_website::vhost'],
      ],
    }
  }
  elsif ( ! empty($certificate_files) ) {
    # READ HASH OF CERTIFICATE FILES AND CONTENTS FROM HIERA
    # CREATE EACH CERTIFICATE FILE WITH RESPECTIVE CONTENT
    $certificate_files.each | $file, $content |
    {
      file { $file:
        ensure  => present,
        owner   => root,
        group   => apache,
        mode    => '0640',
        content => $content,
        notify  => [
          Class['apache::service'],
          Class['profile_website::vhost'],
        ]
      }
    }
  }
  else {
    ## NOTIFY THAT NO SSL OPTIONS WERE PROVIDED
    $notify_text = @("EOT"/)
      No SSL configuration is set. You must set one of the following:
        - \$enable_letsencrypt = true
        - assign \$certificate_files
      | EOT
    notify { $notify_text:
      withpath => true,
    }
  }

}
