# frozen_string_literal: true

require 'find'

Facter.add(:ssl_keys) do
  # https://puppet.com/docs/puppet/latest/fact_overview.html
  setcode do
    keypaths = [
      '/etc/apache2',
      '/etc/certbot/live',
      '/etc/http',
      '/etc/letsencrypt/live',
      '/etc/pki/tls/private',
      '/etc/ssl/private',
    ]
    keys = []

    keypaths.each do |keypath|
      next unless File.exist?(keypath)
      Find.find(keypath).grep(%r{key}) do |path|
        Find.prune if path.include? '.git'
        next if path.include? 'chain'
        next if path.include? 'csr'
        next if path.include? 'README'
        next unless File.file?(path)
        keys << path
      end
    end
    keys.sort
  end
end
