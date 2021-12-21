# profile_website

![pdk-validate](https://github.com/ncsa/puppet-profile_website/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_website/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - configure an Apache HTTPd website

## Usage

To install and configure:

```
  include profile_website
```

## Configuration

The following [`apache`](https://forge.puppet.com/modules/puppetlabs/apache/reference) parameters need to be set:
```
apache::default_ssl_cert: "/etc/letsencrypt/live/%{facts.fqdn}/cert.pem"
apache::default_ssl_chain: "/etc/letsencrypt/live/%{facts.fqdn}/chain.pem"
apache::default_ssl_key: "/etc/letsencrypt/live/%{facts.fqdn}/privkey.pem"
apache::mod::ssl:
  # WITH PARAMETERS
apache::mpm_module: "prefork"

apache::vhost:
  # WITH PARAMETERS
```

Below is a working hiera example to create Apache virtual hosts for the fully qualified domain of a host:
```
apache::default_mods: false
apache::default_vhost: false
apache::default_ssl_vhost: false
apache::default_ssl_cert: "/etc/letsencrypt/live/%{facts.fqdn}/fullchain.pem"
apache::default_ssl_key: "/etc/letsencrypt/live/%{facts.fqdn}/privkey.pem"
apache::access_log_file: "|/usr/bin/logger -t httpd -p local6.info"
apache::error_log_file: "syslog:local6"
apache::mod::ssl:
  ssl_cipher: "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH"
  ssl_compression: false
  ssl_honorcipherorder: true
  ssl_protocol:
    - "all"
    - "-SSLv2"
    - "-SSLv3"
    - "-TLSv1"
    - "-TLSv1.1"
  ssl_stapling: true
  stapling_cache: "shmcb:logs/stapling-cache(150000)"
apache::mpm_module: "prefork"
apache::serveradmin: "web@ncsa.illinois.edu"
apache::server_tokens: "Prod"
apache::server_signature: "Off"
apache::trace_enable: "Off"

apache::vhost:
  "%{facts.fqdn}-ssl":
    servername: "%{facts.fqdn}"
    serveraliases:
      - "%{facts.fqdn}"
    access_log_pipe: "|/bin/sh -c
      '/usr/bin/tee
      -a /var/log/httpd/%{facts.fqdn}-ssl_access_ssl.log'
      |/bin/sh -c '/usr/bin/logger -t httpd -p local6.notice'"
    docroot: "/var/www/html"
    error_log_pipe: "|/bin/sh -c
      '/usr/bin/tee
      -a /var/log/httpd/%{facts.fqdn}-ssl_error_ssl.log'
      |/bin/sh -c '/usr/bin/logger -t httpd -p local6.err'"
    log_level: "warn"
    port: 443
    ssl: true
    headers:
      - "always set Strict-Transport-Security \"max-age=31536000\""
      - "set Content-Security-Policy \"default-src 'self' 'unsafe-inline' 'unsafe-eval' data:;\""
      - "set X-Content-Type-Options nosniff"
    rewrites:
      - comment: "rewrite all urls to use SSL with default hostname"
        rewrite_cond: "%%{}{HTTPS} off"
        rewrite_rule: "(.*)  https://%%{}{SERVER_NAME}/$1 [R,L]"
  "%{facts.fqdn}-nossl":
    servername: "%{facts.fqdn}"
    serveraliases:
      - "%{facts.fqdn}"
    access_log_pipe: "|/bin/sh -c
      '/usr/bin/tee
      -a /var/log/httpd/%{facts.fqdn}-nossl_access.log'
      |/bin/sh -c '/usr/bin/logger -t httpd -p local6.notice'"
    docroot: "/var/www/html"
    error_log_pipe: "|/bin/sh -c
      '/usr/bin/tee
      -a /var/log/httpd/%{facts.fqdn}-nossl_error.log'
      |/bin/sh -c '/usr/bin/logger -t httpd -p local6.err'"
    port: 80
    headers:
      - "always set Strict-Transport-Security \"max-age=31536000\""
      - "set Content-Security-Policy \"default-src 'self' 'unsafe-inline' 'unsafe-eval' data:;\""
      - "set X-Content-Type-Options nosniff"
    rewrites:
      - comment: "rewrite all urls to use SSL with default hostname"
        rewrite_cond: "%%{}{HTTPS} off"
        rewrite_rule: "(.*)  https://%%{}{SERVER_NAME}/$1 [R,L]"
```

## Dependencies
- [puppet/letsencrypt](https://forge.puppet.com/modules/puppet/letsencrypt)
- [puppetlabs/apache](https://forge.puppet.com/modules/puppetlabs/apache)
- [puppetlabs/firewall](https://forge.puppet.com/puppetlabs/firewall)
- [puppetlabs/stdlib](https://forge.puppet.com/modules/puppetlabs/stdlib)

## Reference

[REFERENCE.md](REFERENCE.md)

