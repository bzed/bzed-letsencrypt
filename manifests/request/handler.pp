# == Class: letsencrypt
#
# Include this class if you would like to create
# Certificates or on your puppetmaster to have you CSRs signed.
#
#
# === Parameters
#
# [*letsencrypt_sh_git_url*]
#   URL used to checkout the letsencrypt.sh using git.
#   Defaults to the upstream github url.
#
# [*hook_source*]
#   Points to the source of the letsencrypt.sh hook you'd like to
#   distribute ((as in file { ...: source => })
#   hook_source or hook_content needs to be specified.
#
# [*hook_content*]
#   The actual content (as in file { ...: content => }) of the
#   letsencrypt.sh hook.
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
    $letsencrypt_sh_git_url,
    $hook_source,
    $hook_content

){

    require ::letsencrypt::params

    $handler_base_dir     = $::letsencrypt::params::handler_base_dir
    $handler_requests_dir = $::letsencrypt::params::handler_requests_dir
    $letsencrypt_sh_dir   = $::letsencrypt::params::letsencrypt_sh_dir
    $letsencrypt_sh_hook  = $::letsencrypt::params::letsencrypt_sh_hook
    $letsencrypt_sh_conf  = $::letsencrypt::params::letsencrypt_sh_conf

    user { 'letsencrypt' :
        gid        => 'letsencrypt',
        home       => $handler_base_dir,
        shell      => '/bin/bash',
        managehome => false,
        password   => '!!'
    }

    File {
        owner => root,
        group => root
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

    file { $letsencrypt_sh_hook :
        ensure  => present,
        group   => 'letsencrypt',
        require => Group['letsencrypt'],
        source  => $hook_source,
        content => $hook_content,
        mode    => '0750'
    }

    vcsrepo { $letsencrypt_sh_dir :
        ensure   => latest,
        revision => master,
        provider => git,
        source   => $letsencrypt_sh_git_url,
        user     => root,
        require  => File[$handler_base_dir]
    }

    file { $letsencrypt_sh_conf :
        ensure  => file,
        owner   => root,
        group   => letsencrypt,
        mode    => '0640',
        content => template('letsencrypt/letsencrypt.conf.erb')
    }

    Letsencrypt::Request <<| tag == $::fqdn |>>
}
