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

bzed-letsencrypy is a flexible wrapper around certificate
creation and signing around letsencrypt.sh - with the
advantage that you private keys are never shipped by puppet.

## Module Description

bzed-letsencrypy creates private keys and CSRs, transfers
the CSR to a puppetmaster where it is signed using
the well known letsencrypt.sh
https://github.com/lukas2511/letsencrypt.sh

Signed certificates are shipped back to the appropriate host.

You need to provide an appropriate hook script for letsencryt.sh,
The default is to use the DNS-01 challenge, but if you hook
supports it you could also create the necessary files for http-01.

Various examples for valid DNS-01 hooks are listed on
https://github.com/lukas2511/letsencrypt.sh/wiki/Examples-for-DNS-01-hooks

## Setup

### What letsencrypt affects


* letsencrypt.sh is running at the puppetmaster host as it is easier
  to read and work with certificate files stored directly on the puppet
  master. Retrieving them using facter is unnecessarily complicated.


### Setup Requirements

You need to ensure that exported ressources are working and pluginsync
is enabled.

### Beginning with letsencrypt

In the best case: add the letsencrupt class and override $domains
with a list of domains you want to get certificates for.

## Usage
On a puppet node where you need your certificates:
~~~puppet
    class { 'letsencrypt' :
        domains     => [ 'foo.example.com', 'fuzz.example.com' ],
    }
~~~
Key and CSR will be generated on your node and the CSR
is shipped to your puppetmaster for signing.

On your puppetmaster:
~~~puppet
    class { 'letsencrypt' :
        hook_source => 'puppet:///modules/mymodule/letsencrypt_sh_hook'
    }
~~~
CSRs are collected and signed, and the resulting
certificates and CA chain files are shipped back to your node.


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

Not really well tested yet, no spec tests....

## Development

Patches are very welcome!


