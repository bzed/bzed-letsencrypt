# = Define: letsencrypt::crt
#
# Used as exported ressource to ship a signed CRT.
#
# == Parameters:
#
# [*crt_content*]
#   actual certificate content.
#
# [*crt_chain_content*]
#   actual certificate chain file content.
#
# [*dh_content*]
#   dh file content.
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
    $ocsp_content,
    $domain = $name
) {

    require ::letsencrypt::params

    $crt_dir                 = $::letsencrypt::params::crt_dir
    $key_dir                 = $::letsencrypt::params::key_dir
    $crt                     = "${crt_dir}/${domain}.crt"
    $ocsp                    = "${crt_dir}/${domain}.crt.ocsp"
    $key                     = "${key_dir}/${domain}.key"
    $dh                      = "${crt_dir}/${domain}.dh"
    $crt_chain               = "${crt_dir}/${domain}_ca.pem"
    $crt_full_chain          = "${crt_dir}/${domain}_fullchain.pem"
    $crt_full_chain_with_key = "${key_dir}/${domain}_fullchain_with_key.pem"

    file { $crt :
        ensure  => file,
        owner   => root,
        group   => letsencrypt,
        content => $crt_content,
        mode    => '0644',
    }

    if !empty($ocsp_content) {
        file { $ocsp :
            ensure  => file,
            owner   => root,
            group   => letsencrypt,
            content => base64('decode', $ocsp_content),
            mode    => '0644',
        }
    } else {
        file { $ocsp :
            ensure => absent,
            force  => true,
        }
    }

    concat { $crt_full_chain :
        owner => root,
        group => letsencrypt,
        mode  => '0644',
    }
    concat { $crt_full_chain_with_key :
        owner => root,
        group => letsencrypt,
        mode  => '0640',
    }

    concat::fragment { "${domain}_key" :
        target => $crt_full_chain_with_key,
        source => $key,
        order  => '01',
    }
    concat::fragment { "${domain}_fullchain" :
        target    => $crt_full_chain_with_key,
        source    => $crt_full_chain,
        order     => '10',
        subscribe => Concat[$crt_full_chain],
    }

    concat::fragment { "${domain}_crt" :
        target  => $crt_full_chain,
        content => $crt_content,
        order   => '10',
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
    } else {
        file { $dh :
            ensure => absent,
            force  => true,
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
    } else {
        file { $crt_chain :
            ensure => absent,
            force  => true,
        }
    }

}
