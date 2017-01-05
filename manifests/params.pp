# == Class: letsencrypt::params
#
# Some basic variables we want to use.
#
# === Authors
#
# Author Name Bernd Zeimetz <bernd@bzed.de>
#
# === Copyright
#
# Copyright 2016 Bernd Zeimetz
#



class letsencrypt::params {

    $base_dir = '/etc/letsencrypt'
    $handler_base_dir = '/opt/letsencrypt'

    $letsencrypt_chain_request = "letsencrypt_get_certificate_chain.sh"
    $letsencrypt_ocsp_request = "letsencrypt_get_certificate_ocsp.sh"

    if defined('$puppetmaster') {
        $letsencrypt_host = $::puppetmaster
    } elsif defined('$servername') {
        $letsencrypt_host = $::servername
    }

    $letsencrypt_sh_git_url = 'https://github.com/lukas2511/dehydrated.git'
    $dehydrated_git_url = $letsencrypt_sh_git_url
    $challengetype = 'dns-01'
    $letsencrypt_ca = 'https://acme-v01.api.letsencrypt.org/directory'
    $dh_param_size = 2048
    $manage_packages = true

}
