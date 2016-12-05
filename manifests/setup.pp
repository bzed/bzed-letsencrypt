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
) {

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

    file { $::letsencrypt::base_dir : }
    file { $::letsencrypt::csr_dir : }
    file { $::letsencrypt::crt_dir : }
    file { $::letsencrypt::key_dir :
        mode    => '0750',
    }

    file { "/etc/letsencrypt.basedir":
        ensure      => file,
        content     => $::letsencrypt::base_dir
    }

}
