# == Class: letsencrypt
#
# Include this class if you would like to create
# Certificates or on your puppetmaster to have you CSRs signed.
#
#
# === Parameters
#
# [*dehydrated_git_url*]
#   URL used to checkout the dehydrated using git.
#   Defaults to the upstream github url.
#
# [*hook_source*]
#   Points to the source of the dehydrated hook you'd like to
#   distribute ((as in file { ...: source => })
#   hook_source or hook_content needs to be specified.
#
# [*hook_content*]
#   The actual content (as in file { ...: content => }) of the
#   dehydrated hook.
#   hook_source or hook_content needs to be specified.
#
# === Authors
#
# Author Name Bernd Zeimetz <bernd@bzed.de>
#
# === Copyright
#
# Copyright 2016 Bernd Zeimetz
#


class letsencrypt::request::handler(
    $dehydrated_git_url,
    $letsencrypt_cas,
    $letsencrypt_ca,
    $hook_source,
    $hook_content,
    $letsencrypt_contact_email,
    $letsencrypt_proxy,
    $domain_validation_hook_source = undef,
    $domain_validation_hook_content = undef,
    $domain_validation_hook = $::letsencrypt::params::domain_validation_hook,
    $handler_base_dir = $::letsencrypt::params::handler_base_dir,
    $handler_requests_dir = $::letsencrypt::params::handler_requests_dir,
    $dehydrated_dir = $::letsencrypt::params::dehydrated_dir,
    $dehydrated_hook = $::letsencrypt::params::dehydrated_hook,
    $dehydrated_conf = $::letsencrypt::params::dehydrated_conf,
    $letsencrypt_chain_request = $::letsencrypt::params::letsencrypt_chain_request,
    $letsencrypt_ocsp_request = $::letsencrypt::params::letsencrypt_ocsp_request,
    $letsencrypt_check_altnames = $::letsencrypt::params::letsencrypt_check_altnames,
) inherits ::letsencrypt::params {

    require ::letsencrypt::params

    if (!empty($letsencrypt_proxy)) {
      $letsencrypt_proxy_without_protocol = regsubst($letsencrypt_proxy, '^.*://', '')
    }

    if $::letsencrypt::manage_user {
        user { $::letsencrypt::user:
            gid        => $::letsencrypt::group,
            home       => $handler_base_dir,
            shell      => '/bin/bash',
            managehome => false,
            password   => '!!',
        }
    }

    File {
        owner => root,
        group => root,
    }

    file { $handler_base_dir :
        ensure => directory,
        mode   => '0755',
        owner  => $::letsencrypt::user,
        group  => $::letsencrypt::group,
    }
    file { "${handler_base_dir}/.acme-challenges" :
        ensure => directory,
        mode   => '0755',
        owner  => $::letsencrypt::user,
        group  => $::letsencrypt::group,
    }
    file { $handler_requests_dir :
        ensure => directory,
        mode   => '0755',
    }

    file { $dehydrated_hook :
        ensure  => file,
        group   => $::letsencrypt::group,
        require => Group[$::letsencrypt::group],
        source  => $hook_source,
        content => $hook_content,
        mode    => '0750',
    }

    if (!empty($domain_validation_hook_source) or !empty($domain_validation_hook_content)) {
        file { $domain_validation_hook :
            ensure  => file,
            group   => $::letsencrypt::group,
            require => Group[$::letsencrypt::group],
            source  => $domain_validation_hook_source,
            content => $domain_validation_hook_content,
            mode    => '0750',
            before  => File[$dehydrated_hook],
        }
    } else {
        $exit0 = join(['#!/bin/bash', '', 'exit 0', '',], "\n")

        file { $domain_validation_hook :
            ensure  => file,
            group   => $::letsencrypt::group,
            require => Group[$::letsencrypt::group],
            content => $exit0,
            mode    => '0750',
            before  => File[$dehydrated_hook],
        }
    }


    vcsrepo { $dehydrated_dir :
        ensure   => latest,
        revision => master,
        provider => git,
        source   => $dehydrated_git_url,
        user     => root,
        require  => [
            File[$handler_base_dir],
            Package['git']
        ],
    }

    # handle switching CAs with different account keys.
    $ca_hash = $letsencrypt_cas[$letsencrypt_ca]['hash']
    $ca_url  = $letsencrypt_cas[$letsencrypt_ca]['url']

    file { $dehydrated_conf :
        ensure  => file,
        owner   => root,
        group   => $::letsencrypt::group,
        mode    => '0640',
        content => template('letsencrypt/letsencrypt.conf.erb'),
    }

    file { $letsencrypt_chain_request :
        ensure  => file,
        owner   => root,
        group   => $::letsencrypt::group,
        mode    => '0755',
        content => template('letsencrypt/letsencrypt_get_certificate_chain.sh.erb'),
    }

    $openssl_11 = (versioncmp($::openssl_version, '1.1') >=0)

    file { $letsencrypt_ocsp_request :
        ensure  => file,
        owner   => root,
        group   => $::letsencrypt::group,
        mode    => '0755',
        content => template('letsencrypt/letsencrypt_get_certificate_ocsp.sh.erb'),
    }

    Letsencrypt::Request<<| tag == "crt-host-${::fqdn}" |>>

    file { $letsencrypt_check_altnames :
        ensure  => file,
        owner   => root,
        group   => letsencrypt,
        mode    => '0755',
        content => file('letsencrypt/letsencrypt_check_altnames.sh'),
    }

}
