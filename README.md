# letsencrypt

[![Puppet Forge](http://img.shields.io/puppetforge/v/bzed/letsencrypt.svg)](https://forge.puppetlabs.com/bzed/letsencrypt) [![Build Status](https://travis-ci.org/bzed/bzed-letsencrypt.png?branch=master)](https://travis-ci.org/bzed/bzed-letsencrypt)


#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with letsencrypt](#setup)
    * [What letsencrypt affects](#what-letsencrypt-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with letsencrypt](#beginning-with-letsencrypt)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Centralized CSR signing using Let’s Encrypt™ - keeping your keys safe on the host they belong to.

## Module Description

bzed-letsencrypy creates private keys and CSRs, transfers
the CSR to a puppetmaster where it is signed using
the well known dehydrated
https://github.com/lukas2511/dehydrated

Signed certificates are shipped back to the appropriate host.

You need to provide an appropriate hook script for letsencryt.sh,
The default is to use the DNS-01 challenge, but if you hook
supports it you could also create the necessary files for http-01.

Let’s Encrypt is a trademark of the Internet Security Research Group. All rights reserved.

## Setup

### What letsencrypt affects


* dehydrated is running at the puppetmaster host as it is easier
  to read and work with certificate files stored directly on the puppet
  master. Retrieving them using facter is unnecessarily complicated.


### Setup Requirements

You need to ensure that exported ressources are working and pluginsync
is enabled.

### Beginning with letsencrypt

In the best case: add the letsencrypt class and override $domains
with a list of domains you want to get certificates for.

## Usage
### On puppet nodes
On a puppet node where you need your certificates:
~~~puppet
    class { 'letsencrypt' :
        domains     => [ 'foo.example.com', 'fuzz.example.com' ],
    }
~~~
Key and CSR will be generated on your node and the CSR
is shipped to your puppetmaster for signing - the puppetmaster needs
a public interface and the cert is put on your node after some time.

Additionally to or instead of specifying the domains as
parameter to the letsencrypt class, it is possible to
call the letsencrypt::certificate define directly:

~~~puppet
    ::letsencrypt::certificate { 'foo.example.com' :
    }
~~~

#### SAN Certificates
Requesting SAN certificates is also possible. To do so pass a
space seperated list of domainnames into the domains array.
The first domainname in each list is used as the base domain
for the request. For example:
~~~puppet
    class { 'letsencrypt' :
        domains     => [
            'foo.example.com bar.example.com good.example.com',
            'fuzz.example.com'
        ],
    }
~~~

And/or:
~~~puppet
    ::letsencrypt::certificate { 'foo.example.com bar.example.com good.example.com' :
    }
~~~


### On your puppetmaster:
What you need to prepare is a hook you want to use with dehydrated
as you need to deploy the challenges somehow. Various examples for
valid DNS-01 hooks are listed on
https://github.com/lukas2511/dehydrated/wiki/Examples-for-DNS-01-hooks

~~~puppet
    class { 'letsencrypt' :
        hook_source => 'puppet:///modules/mymodule/dehydrated_hook'
    }
~~~
CSRs are collected and signed, and the resulting
certificates and CA chain files are shipped back to your node.

#### Testing and Debugging
For testing purposes you want to use the staging CA, otherwise
you'll hit rate limits pretty soon. To do s set the letsencrypt\_ca
option:
~~~puppet
    class { 'letsencrypt' :
        hook_source    => 'puppet:///modules/mymodule/dehydrated_hook',
        letsencrypt_ca => 'https://acme-staging.api.letsencrypt.org/directory',
    }
~~~

## Examples
### Postfix
Using the _camptocamp-postfix_ module:

~~~puppet
    require ::letsencrypt::params
    $myhostname = $::fqdn

    $base_dir = $::letsencrypt::params::base_dir
    $crt_dir  = $::letsencrypt::params::crt_dir
    $key_dir  = $::letsencrypt::params::key_dir

    $postfix_chroot = '/var/spool/postfix'

    $tls_key = "${key_dir}/${myhostname}.key"
    $tls_cert = "${crt_dir}/${myhostname}_fullchain.pem"

    ::letsencrypt::certificate { $myhostname :
        notify => Service['postfix'],
    }

    ::postfix::config { 'smtpd_tls_cert_file' :
        value   => $tls_cert,
        require => Letsencrypt::Certificate[$myhostname]
    }
    ::postfix::config { 'smtpd_tls_key_file' :
        value   => $tls_key,
        require => Letsencrypt::Certificate[$myhostname]
    }
    ::postfix::config { 'smtpd_use_tls' :
        value => 'yes'
    }
    ::postfix::config { 'smtpd_tls_session_cache_database' :
        value => "btree:\${data_directory}/smtpd_scache",
    }
    ::postfix::config { 'smtp_tls_session_cache_database' :
        value => "btree:\${data_directory}/smtp_scache",
    }
    ::postfix::config { 'smtp_tls_security_level' :
        value => 'may',
    }

    file { [
        "${postfix_chroot}/${base_dir}",
        "${postfix_chroot}/${crt_dir}",
    ] :
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { "${postfix_chroot}/${key_dir}" :
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0750',
    }

    file { "${postfix_chroot}/${tls_key}" :
        ensure    => file,
        owner     => 'root',
        group     => 'root',
        mode      => '0640',
        source    => $tls_key,
        subscribe => Letsencrypt::Certificate[$myhostname],
        notify    => Service['postfix'],
    }

    file { "${postfix_chroot}/${tls_cert}" :
        ensure    => file,
        owner     => 'root',
        group     => 'root',
        mode      => '0644',
        source    => $tls_cert,
        subscribe => Letsencrypt::Certificate[$myhostname],
        notify    => Service['postfix'],
    }

~~~

## Reference

Classes:
* letsencrypt
* letsencrypt::params
* letsencrypt::request::handler

Defines:
* letsencrypt::csr
* letsencrypt::deploy
* letsencrypt::deploy::crt
* letsencrypt::request
* letsencrypt::request::crt

Facts:
* letsencrypt\_csrs
* letsencrypt\_csr\_\*
* letsencrypt\_crts

## Limitations

Not really well tested yet, documentation missing, no spec tests....

## Development

Patches are very welcome!
Please send your pull requests on github!

