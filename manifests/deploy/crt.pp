# = Define: letsencrypt::crt
#
# Used as exported ressource to ship a signed CRT.
#
# == Parameters:
#
# [*crt_file*]
#   File which contains the crt.
#
# [*domain*]
#   Certificate commonname / domainname.
#
#
# === Authors
#
# Author Name Bernd Zeimetz <bernd@bzed.de>
#
# === Copyright
#
# Copyright 2016 Bernd Zeimetz
#


define letsencrypt::deploy::crt(
    $crt_content,
    $domain = $name
) {

    require ::letsencrypt::params

    $crt_dir  = $::letsencrypt::params::crt_dir
    $crt      = "${crt_dir}/${domain}.crt"


    file { $crt :
        ensure  => file,
        owner   => root,
        group   => letsencrypt,
        content => $crt_content,
        mode    => '0644',
    }
    notify { 'deploy' :
    }
}
