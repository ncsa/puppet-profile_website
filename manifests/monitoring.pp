# @summary Register monitoring for the website
#
# @param telegraf_sslcert_check_file
#   Full path to telegraf sslcert check file
#
# @param telegraf_website_check_file
#   Full path to telegraf website check file
#
# @example
#   include profile_website::monitoring
class profile_website::monitoring (
  String $telegraf_sslcert_check_file,
  String $telegraf_website_check_file,
) {
  # Set exported resource to populate telegraf sslcert check via ::profile_monitoring::telegraf_sslcert_check
  @@file_line { "exported_telegraf_sslcert_check_${facts['networking']['fqdn']}":
    ensure   => 'present',
    after    => 'sources',
    line     => "    \"https://${facts['networking']['fqdn']}:443\",",
    match    => $facts['networking']['fqdn'],
    multiple => 'false',
    notify   => Service['telegraf'],
    path     => $telegraf_sslcert_check_file,
    tag      => 'telegraf_sslcert_check',
  }

  # Set exported resource to populate telegraf ping check via ::profile_monitoring::telegraf_website_check
  @@file_line { "exported_telegraf_website_check_${facts['networking']['fqdn']}":
    ensure   => 'present',
    after    => 'urls',
    line     => "    \"https://${facts['networking']['fqdn']}\",",
    match    => $facts['networking']['fqdn'],
    multiple => 'false',
    notify   => Service['telegraf'],
    path     => $telegraf_website_check_file,
    tag      => 'telegraf_website_check',
  }
}
