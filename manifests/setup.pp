# == Class: letsencrypt::setup
#
# setup all necessary directories and groups
#
# === Authors
#
# Author Name Bernd Zeimetz <bernd@bzed.de>
#
# === Copyright
#
# Copyright 2016 Bernd Zeimetz
#
class letsencrypt::setup (
){

    require ::letsencrypt::params

    group { 'letsencrypt' :
        ensure => present,
    }

    File {
        ensure  => directory,
        owner   => 'root',
        group   => 'letsencrypt',
        mode    => '0755',
        require => Group['letsencrypt'],
    }

    file { $::letsencrypt::params::base_dir :
    }
    file { $::letsencrypt::params::csr_dir :
    }
    file { $::letsencrypt::params::crt_dir :
    }
    file { $::letsencrypt::params::key_dir :
        mode    => '0750',
    }

    ensure_packages('git')

}
