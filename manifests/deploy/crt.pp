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
    $crt_chain_content,
    $dh_content,
    $domain = $name
) {

    require ::letsencrypt::params

    $crt_dir        = $::letsencrypt::params::crt_dir
    $crt            = "${crt_dir}/${domain}.crt"
    $dh             = "${crt_dir}/${domain}.dh"
    $crt_chain      = "${crt_dir}/${domain}_ca.pem"
    $crt_full_chain = "${crt_dir}/${domain}_fullchain.pem"


    file { $crt :
        ensure  => file,
        owner   => root,
        group   => letsencrypt,
        content => $crt_content,
        mode    => '0644',
    }


    concat { $crt_full_chain :
        owner => root,
        group => letsencrypt,
        mode  => '0644',
    }

    concat::fragment { "${domain}_crt" :
        target  => $crt_full_chain,
        content => $crt_content,
        order   => '01',
    }

    if ($dh_content and $dh_content =~ /BEGIN DH PARAMETERS/) {
        file { $dh :
            ensure  => file,
            owner   => root,
            group   => letsencrypt,
            content => $dh_content,
            mode    => '0644',
        }
        concat::fragment { "${domain}_dh" :
            target  => $crt_full_chain,
            content => $dh_content,
            order   => '30',
        }
    }

    if ($crt_chain_content and $crt_chain_content =~ /BEGIN CERTIFICATE/) {
        file { $crt_chain :
            ensure  => file,
            owner   => root,
            group   => letsencrypt,
            content => $crt_chain_content,
            mode    => '0644',
        }
        concat::fragment { "${domain}_ca" :
            target  => $crt_full_chain,
            content => $crt_chain_content,
            order   => '50',
        }
    }
}
