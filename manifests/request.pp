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
#   challengetype dehydratedould use.
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
    $dehydrated     = $::letsencrypt::params::dehydrated
    $dehydrated_dir = $::letsencrypt::params::dehydrated_dir
    $dehydrated_hook   = $::letsencrypt::params::dehydrated_hook
    $dehydrated_hook_env = $::letsencrypt::hook_env
    $dehydrated_conf   = $::letsencrypt::params::dehydrated_conf
    $letsencrypt_chain_request  = $::letsencrypt::params::letsencrypt_chain_request
    $letsencrypt_check_altnames = $::letsencrypt::params::letsencrypt_check_altnames
    $domain_validation_hook = $::letsencrypt::params::domain_validation_hook

    File {
        owner   => $::letsencrypt::user,
        group   => $::letsencrypt::group,
        require => [
            User[$::letsencrypt::user],
            Group[$::letsencrypt::group]
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

    $_csr_file = shellquote($csr_file)
    $_crt_file = shellquote($_crt_file)
    $_crt_chain_file = shellquote($crt_chain_file)

    $le_check_command = join([
        "/usr/bin/test -f ${_crt_file}",
        '&&',
        "/usr/bin/openssl x509 -checkend 2592000 -noout -in ${_crt_file}",
        '&&',
        "${letsencrypt_check_altnames} ${_csr_file} ${_crt_file}",
        '&&',
        '/usr/bin/test',
        '$(',
        "/usr/bin/stat -c '%Y' ${_crt_file}",
        ')',
        '-gt',
        '$(',
        "/usr/bin/stat -c '%Y' ${_csr_file}",
        ')',
    ], ' ')

    if ($altnames) {
        $validate_domains = shellquote(split("${domain} ${altnames}", ' '))
    } else {
        $validate_domains = shellquote([$domain,])
    }


    $le_command = join([
        $domain_validation_hook,
        $validate_domains,
        '&&',
        $dehydrated,
        '-d', shellquote($domain),
        '-k', shellquote($dehydrated_hook),
        '-t', shellquote($challengetype),
        '-f', shellquote($dehydrated_conf),
        '-a rsa',
        '--signcsr',
        $_csr_file,
        "> ${_crt_file}.new",
        "&& /bin/mv ${_crt_file}.new ${_crt_file}",
    ], ' ')

    exec { "create-certificate-${domain}" :
        user        => $::letsencrypt::user,
        cwd         => $dehydrated_dir,
        group       => $::letsencrypt::group,
        unless      => $le_check_command,
        command     => $le_command,
        environment => $dehydrated_hook_env,
        require     => [
            User[$::letsencrypt::user],
            Group[$::letsencrypt::group],
            File[$csr_file],
            Vcsrepo[$dehydrated_dir],
            File[$dehydrated_hook],
            File[$dehydrated_conf],
        ],
    }

    $get_certificate_chain_command = join([
        $letsencrypt_chain_request,
        $_crt_file,
        $_crt_chain_file,
    ], ' ')
    exec { "get-certificate-chain-${domain}" :
        require     => File[$letsencrypt_chain_request],
        subscribe   => [
            Exec["create-certificate-${domain}"],
            File[$letsencrypt_chain_request]
        ],
        refreshonly => true,
        user        => $::letsencrypt::user,
        group       => $::letsencrypt::group,
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
