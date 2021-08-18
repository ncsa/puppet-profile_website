# frozen_string_literal: true

require 'find'

Facter.add(:ssl_certificates) do
  # https://puppet.com/docs/puppet/latest/fact_overview.html
  setcode do
    certpaths = [
      '/etc/apache2',
      '/etc/certbot/live',
      '/etc/http',
      '/etc/letsencrypt/live',
      '/etc/pki/tls/certs',
      '/etc/ssl/certs',
    ]
    certificates = []

    certpaths.each do |certpath|
      next unless File.exist?(certpath)
      Find.find(certpath) do |path|
        Find.prune if path.include? '.git'
        next if path.include? 'csr'
        next if path.include? 'key'
        next if path.include? 'README'
        next unless File.file?(path)
        certificates << path
      end
    end
    certificates.sort
  end
end
