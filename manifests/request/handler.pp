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
    $letsencrypt_ca,
    $hook_source,
    $hook_content,
    $letsencrypt_contact_email,
    $letsencrypt_proxy,
){

    require ::letsencrypt::params

    $handler_base_dir     = $::letsencrypt::params::handler_base_dir
    $handler_requests_dir = $::letsencrypt::params::handler_requests_dir
    $dehydrated_dir   = $::letsencrypt::params::dehydrated_dir
    $dehydrated_hook  = $::letsencrypt::params::dehydrated_hook
    $dehydrated_conf  = $::letsencrypt::params::dehydrated_conf
    $letsencrypt_chain_request  = $::letsencrypt::params::letsencrypt_chain_request
    $letsencrypt_ocsp_request   = $::letsencrypt::params::letsencrypt_ocsp_request

    user { 'letsencrypt' :
        gid        => 'letsencrypt',
        home       => $handler_base_dir,
        shell      => '/bin/bash',
        managehome => false,
        password   => '!!',
    }

    File {
        owner => root,
        group => root,
    }

    file { $handler_base_dir :
        ensure => directory,
        mode   => '0755',
        owner  => 'letsencrypt',
        group  => 'letsencrypt',
    }
    file { "${handler_base_dir}/.acme-challenges" :
        ensure => directory,
        mode   => '0755',
        owner  => 'letsencrypt',
        group  => 'letsencrypt',
    }
    file { $handler_requests_dir :
        ensure => directory,
        mode   => '0755',
    }

    file { $dehydrated_hook :
        ensure  => file,
        group   => 'letsencrypt',
        require => Group['letsencrypt'],
        source  => $hook_source,
        content => $hook_content,
        mode    => '0750',
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
    if ($letsencrypt_ca =~ /.*acme-v01\.api\.letsencrypt\.org.*/) {
        $private_key_name = 'private_key'
    } else {
        $_ca_domain = regsubst(
            $letsencrypt_ca,
            '^https?://([^/]+)/.*',
            '\1'
        )
        $_ca_domain_escaped = regsubst(
            $_ca_domain,
            '\.',
            '_',
            'G'
        )
        $private_key_name = "private_key_${_ca_domain_escaped}"
    }
    file { $dehydrated_conf :
        ensure  => file,
        owner   => root,
        group   => letsencrypt,
        mode    => '0640',
        content => template('letsencrypt/letsencrypt.conf.erb'),
    }

    file { $letsencrypt_chain_request :
        ensure  => file,
        owner   => root,
        group   => letsencrypt,
        mode    => '0755',
        content => template('letsencrypt/letsencrypt_get_certificate_chain.sh.erb'),
    }

    file { $letsencrypt_ocsp_request :
        ensure  => file,
        owner   => root,
        group   => letsencrypt,
        mode    => '0755',
        content => template('letsencrypt/letsencrypt_get_certificate_ocsp.sh.erb'),
    }

    Letsencrypt::Request<<| tag == "CRT_HOST=${::fqdn}" |>>
}
