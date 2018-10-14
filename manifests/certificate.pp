# == Define: letsencrypt::certificate
#
# Request a certificate for a single domain or a SAN certificate.
#
# === Parameters
#
# [*domain*]
#   Full qualified domain names (== commonname)
#   you want to request a certificate for.
#   For SAN certificates you need to pass space seperated strings,
#   for example 'foo.example.com fuzz.example.com'
#
# [*channlengetype*]
#   Challenge type to use, defaults to $::letsencrypt::challengetype
#
# [*letsencrypt_host*]
#   The host you want to run dehydrated on.
#   Defaults to $::letsencrypt::letsencrypt_host
#
# [*dh_param_size*]
#   dh parameter size, defaults to $::letsencrypt::dh_param_size
#
# === Examples
#   ::letsencryt::certificate( 'foo.example.com' :
#   }
#
# === Authors
#
# Author Name Bernd Zeimetz <bernd@bzed.de>
#
# === Copyright
#
# Copyright 2016 Bernd Zeimetz
#
define letsencrypt::certificate (
    $domain = $name,
    $challengetype = $::letsencrypt::challengetype,
    $letsencrypt_host = $::letsencrypt::letsencrypt_host,
    $dh_param_size = $::letsencrypt::dh_param_size,
){

    validate_integer($dh_param_size)
    validate_string($letsencrypt_host)
    validate_re($challengetype, '^(http-01|dns-01)$')
    validate_string($domain)

    require ::letsencrypt::params
    require ::letsencrypt::setup

    ::letsencrypt::deploy { $domain :
        letsencrypt_host => $letsencrypt_host,
    }
    ::letsencrypt::csr { $domain :
        letsencrypt_host => $letsencrypt_host,
        challengetype    => $challengetype,
        dh_param_size    => $dh_param_size,
    }

    deprecation(
      'bzed-letsencrypt-deprecated',
      'bzed-letsencrypt is deprecated, please use bzed-dehydrated instead!'
    )
}
