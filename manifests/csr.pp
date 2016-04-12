# = Define: letsencrypt::csr
#
# Create a CSR and ask to sign it.
#
# == Parameters:
#
# [*letsencrypt_host*]
#   Host the certificates were signed on
#
# [*challengetype*]
#   challengetype letsencrypt should use.
#
#  .... plus various other undocumented parameters
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


define letsencrypt::csr(
    $letsencrypt_host,
    $challengetype,
    $domain_list = $name,
    $country = undef,
    $state = undef,
    $locality = undef,
    $organization = undef,
    $unit = undef,
    $email = undef,
    $password = undef,
    $ensure = 'present',
    $force = true,
    $dh_param_size = 2048,
) {
    require ::letsencrypt::params

    validate_string($country)
    validate_string($organization)
    validate_string($domain_list)
    validate_string($ensure)
    validate_string($state)
    validate_string($locality)
    validate_string($unit)
    validate_string($email)
    validate_integer($dh_param_size)

    $base_dir = $::letsencrypt::params::base_dir
    $csr_dir  = $::letsencrypt::params::csr_dir
    $key_dir  = $::letsencrypt::params::key_dir
    $crt_dir  = $::letsencrypt::params::crt_dir

    $domains = split($domain_list, ' ')
    $domain = $domains[0]
    if (size(domains) > 1) {
        $req_ext = true
        $altnames = delete_at($domains, 0)
        $subject_alt_names = $domains
    } else {
        $req_ext = false
        $altnames = []
        $subject_alt_names = []
    }

    $cnf = "${base_dir}/${domain}.cnf"
    $crt = "${crt_dir}/${domain}.crt"
    $key = "${key_dir}/${domain}.key"
    $csr = "${csr_dir}/${domain}.csr"
    $dh  = "${crt_dir}/${domain}.dh"

    $create_dh_unless = join([
        '/usr/bin/test',
        '-f',
        "'${dh}'",
        '&&',
        '/usr/bin/test',
        '$(',
        "/usr/bin/stat -c '%Y' ${dh}",
        ')',
        '-gt',
        '$(',
        "/bin/date --date='1 month ago' '+%s'",
        ')',
    ], ' ')

    exec { "create-dh-${dh}" :
        require => [
            User['letsencrypt'],
            File[$crt_dir]
        ],
        user    => letsencrypt,
        group   => letsencrypt,
        command => "/usr/bin/openssl dhparam -check ${dh_param_size} -out ${dh}",
        unless  => $create_dh_unless,
        timeout => 30*60,
    }

    file { $dh :
        ensure  => $ensure,
        owner   => 'root',
        group   => 'letsencrypt',
        mode    => '0644',
        require => Exec["create-dh-${dh}"]
    }

    file { $cnf :
        ensure  => $ensure,
        owner   => 'root',
        group   => 'letsencrypt',
        mode    => '0644',
        content => template('letsencrypt/cert.cnf.erb'),
    }

    ssl_pkey { $key :
        ensure   => $ensure,
        password => $password,
        require  => File[$key_dir],
    }
    x509_request { $csr :
        ensure      => $ensure,
        template    => $cnf,
        private_key => $key,
        password    => $password,
        force       => $force,
        require     => File[$cnf],
    }

    file { $key :
        ensure  => $ensure,
        owner   => 'root',
        group   => 'letsencrypt',
        mode    => '0640',
        require => Ssl_pkey[$key],
    }
    file { $csr :
        ensure  => $ensure,
        owner   => 'root',
        group   => 'letsencrypt',
        mode    => '0644',
        require => X509_request[$csr],
    }

    $csr_content = getvar("::letsencrypt_csr_${domain}")
    if ($csr_content =~ /CERTIFICATE REQUEST/) {
        @@letsencrypt::request { $domain :
            csr           => $csr_content,
            tag           => $letsencrypt_host,
            challengetype => $challengetype,
            altnames      => $altnames,
        }
    } else {
        notify { "no CSR from facter for domain ${domain}" : }
    }

}
