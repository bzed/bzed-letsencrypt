define letsencrypt::csr(
    $domain = $name,
    $country = '',
    $state = '',
    $locality = '',
    $organization = '',
    $unit = '',
    $email = '',
    $altnames = [],
    $password = '',
    $ensure = 'present',
    $force = true,
) {
    require ::letsencrypt::params

    $base_dir = $::letsencrypt::params::base_dir
    $csr_dir  = $::letsencrypt::params::csr_dir
    $key_dir  = $::letsencrypt::params::key_dir
    $crt_dir  = $::letsencrypt::params::crt_dir

    $cnf = "${base_dir}/${domain}.cnf"
    $crt = "${crt_dir}/${domain}.crt"
    $key = "${key_dir}/${domain}.key"
    $csr = "${csr_dir}/${domain}.csr"

    validate_string($country)
    validate_string($organization)
    validate_string($domain)
    validate_string($ensure)
    validate_string($state)
    validate_string($locality)
    validate_string($unit)
    validate_array($altnames)
    validate_string($email)

    if !empty($altnames) {
        $req_ext = true
    } else {
        $req_ext = false
    }

    file { $cnf :
        ensure  => $ensure,
        owner   => 'root',
        group   => 'letsencrypt',
        mode    => '0644',
        content => template('letsencrypt/cert.cnf.erb')
    }

    ssl_pkey { $key :
        ensure   => $ensure,
        password => $password,
    }
    x509_request { $csr :
        ensure      => $ensure,
        template    => $cnf,
        private_key => $key,
        password    => $password,
        force       => $force,
        require     => File[$cnf]
    }

    file { $key :
        ensure  => $ensure,
        owner   => 'root',
        group   => 'letsencrypt',
        mode    => '0640',
        require => Ssl_pkey[$key]
    }
    file { $csr :
        ensure  => $ensure,
        owner   => 'root',
        group   => 'letsencrypt',
        mode    => '0644',
        require => X509_request[$csr]
    }

    $csr_content = getvar("::letsencrypt_csr_${domain}")
    if ($csr_content =~ /CERTIFICATE REQUEST/) {
        @@letsencrypt::request { $domain :
            csr => $csr_content,
            tag => $::puppetmaster
        }
    } else {
        notice { "no CSR from facter for domain ${domain}" : }
    }
    
}
