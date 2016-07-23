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
    $domain = $name,
    $altnames = undef,
) {

    require ::letsencrypt::params

    $handler_requests_dir = $::letsencrypt::params::handler_requests_dir

    $base_dir = "${handler_requests_dir}/${domain}"
    $csr_file = "${base_dir}/${domain}.csr"
    $crt_file = "${base_dir}/${domain}.crt"
    $crt_chain_file     = "${base_dir}/${domain}_ca.pem"
    $letsencrypt_sh     = $::letsencrypt::params::letsencrypt_sh
    $letsencrypt_sh_dir = $::letsencrypt::params::letsencrypt_sh_dir
    $letsencrypt_sh_hook   = $::letsencrypt::params::letsencrypt_sh_hook
    $letsencrypt_sh_conf   = $::letsencrypt::params::letsencrypt_sh_conf
    $letsencrypt_chain_request  = $::letsencrypt::params::letsencrypt_chain_request


    File {
        owner   => 'letsencrypt',
        group   => 'letsencrypt',
        require => [
            User['letsencrypt'],
            Group['letsencrypt']
        ],
    }

    file { $base_dir :
        ensure => directory,
        mode   => '0755',
    }

    file { $csr_file :
        ensure  => file,
        content => $csr,
        mode    => '0640',
    }

    $le_check_command = join([
        "/usr/bin/test -f ${crt_file}",
        "/usr/bin/openssl x509 -checkend 2592000 -noout -in ${crt_file}",
    ], ' && ')

    $le_command = join([
        $letsencrypt_sh,
        "-d ${domain}",
        "-k ${letsencrypt_sh_hook}",
        "-t ${challengetype}",
        "-f ${letsencrypt_sh_conf}",
        '-a rsa',
        '--signcsr',
        $csr_file,
        "> ${crt_file}.new",
        "&& /bin/mv ${crt_file}.new ${crt_file}",
    ], ' ')

    exec { "create-certificate-${domain}" :
        user    => 'letsencrypt',
        cwd     => $letsencrypt_sh_dir,
        group   => 'letsencrypt',
        unless  => $le_check_command,
        command => $le_command,
        require => [
            User['letsencrypt'],
            Group['letsencrypt'],
            File[$csr_file],
            Vcsrepo[$letsencrypt_sh_dir],
            File[$letsencrypt_sh_hook],
            File[$letsencrypt_sh_conf],
        ],
    }

    $get_certificate_chain_command = join([
        $letsencrypt_chain_request,
        $crt_file,
        $crt_chain_file,
    ], ' ')
    exec { "get-certificate-chain-${domain}" :
        require     => File[$letsencrypt_chain_request],
        subscribe   => [
            Exec["create-certificate-${domain}"],
            File[$letsencrypt_chain_request]
        ],
        refreshonly => true,
        user        => letsencrypt,
        group       => letsencrypt,
        command     => $get_certificate_chain_command,
        timeout     => 5*60,
        tries       => 2,
    }


    # remove dh files from old module versions
    # TODO: remove again in the future.
    $dh_file  = "${base_dir}/${domain}.dh"
    file { $dh_file:
        ensure => absent,
        force  => true,
    }

    file { $crt_file :
        mode    => '0644',
        replace => false,
        require => Exec["create-certificate-${domain}"],
    }

    ::letsencrypt::request::ocsp { $domain :
        require => File[$crt_file],
    }

}
