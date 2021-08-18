# @summary Configure SSL certificates for apache httpd
#
# @param certificate_files
#   certificate files and contents for manually configured certificates
#
# @param enable_letsencrypt
#   Enable lets encrypt for ssl certificate management
#
# @example
#   include profile_website::ssl
class profile_website::ssl (
  Hash[String,String] $certificate_files,
  Boolean             $enable_letsencrypt,
) {

  if $enable_letsencrypt {
    # https://forge.puppet.com/modules/bodgit/php
    # include ::php
  }
  elsif $certificate_files {
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
        notify  => Class['apache::service']
      }
    }
  }
  else {
    ## NOTIFY THAT NO SSL OPTIONS WERE PROVIDED
  }

}
