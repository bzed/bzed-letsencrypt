# = Define: letsencrypt::request
#
# Request to sign a CSR.
#
# == Parameters:
#
# [*csr*]
#   The full csr as string.
#
# [*domain*]
#   Certificate commonname / domainname.
#
# [*challengetype*]
#   challengetype letsencrypt should use.
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


define letsencrypt::request (
    $csr,
    $challengetype,
    $domain = $name
) {

    require ::letsencrypt::params

    $handler_requests_dir = $::letsencrypt::params::handler_requests_dir

    $base_dir = "${handler_requests_dir}/${domain}"
    $csr_file = "${base_dir}/${domain}.csr"
    $crt_file = "${base_dir}/${domain}.crt"
    $letsencrypt_sh     = $::letsencrypt::params::letsencrypt_sh
    $letsencrypt_sh_dir = $::letsencrypt::params::letsencrypt_sh_dir
    $letsencrypt_hook   = $::letsencrypt::params::letsencrypt_sh_hook

    File {
        owner   => 'letsencrypt',
        group   => 'letsencrypt',
        require => [
            User['letsencrypt'],
            Group['letsencrypt']
        ]
    }

    file { $base_dir :
        ensure => directory,
        mode   => '0750'
    }

    file { $csr_file :
        ensure  => file,
        content => $csr,
        mode    => '0640'
    }

    $le_check_command = join([
        "/usr/bin/test -f ${crt_file}",
        "/usr/bin/openssl x509 -checkend 2592000 -noout -in ${crt_file}"
    ], ' && ')

    $le_command = join([
        $letsencrypt_sh,
        "-d ${domain}",
        "-f ${letsencrypt_hook}",
        "-t ${challengetype}",
        '-a rsa',
        '--signcsr',
        $csr_file,
        "> ${crt_file}.new",
        "&& /bin/mv ${crt_file}.new ${crt_file}"
    ], ' ')

    exec { "create-certificate-${domain}" :
        user    => 'letsencrypt',
        group   => 'letsencrypt',
        unless  => $le_check_command,
        command => $le_command,
        require => [
            User['letsencrypt'],
            Group['letsencrypt'],
            File[$csr_file],
            Vcsrepo[$letsencrypt_sh_dir],
            File[$letsencrypt_hook]
        ],

    }

    if (check_certificate($crt_file)) {
        @@letsencrypt::deploy::crt { $domain :
            crt_file => $crt_file,
            tag      => $::fqdn,
        }
    }

}
