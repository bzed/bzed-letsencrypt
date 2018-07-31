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
    $csr_dir  = "${base_dir}/csr"
    $key_dir  = "${base_dir}/private"
    $crt_dir  = "${base_dir}/certs"

    $handler_base_dir = '/opt/letsencrypt'
    $handler_requests_dir  = "${handler_base_dir}/requests"

    $dehydrated_dir         = "${handler_base_dir}/dehydrated"
    $dehydrated_hook        = "${handler_base_dir}/letsencrypt_hook"
    $dehydrated_hook_env    =  []
    $domain_validation_hook = "${handler_base_dir}/domain_validation_hook"
    $dehydrated_conf        = "${handler_base_dir}/letsencrypt.conf"
    $dehydrated             = "${dehydrated_dir}/dehydrated"

    $letsencrypt_chain_request = "${handler_base_dir}/letsencrypt_get_certificate_chain.sh"
    $letsencrypt_ocsp_request = "${handler_base_dir}/letsencrypt_get_certificate_ocsp.sh"
    $letsencrypt_check_altnames = "${handler_base_dir}/letsencrypt_check_altnames.sh"

    if defined('$puppetmaster') {
        $letsencrypt_host = $::puppetmaster
    } elsif defined('$servername') {
        $letsencrypt_host = $::servername
    }

    $letsencrypt_sh_git_url = 'https://github.com/lukas2511/dehydrated.git'
    $dehydrated_git_url = $letsencrypt_sh_git_url
    $challengetype = 'dns-01'
    $letsencrypt_ca = 'production'
    $letsencrypt_cas = {
      'production' => {
        'url'  => 'https://acme-v01.api.letsencrypt.org/directory',
        'hash' => 'aHR0cHM6Ly9hY21lLXYwMS5hcGkubGV0c2VuY3J5cHQub3JnL2RpcmVjdG9yeQo'
      },
      'staging'    => {
        'url'  => 'https://acme-staging.api.letsencrypt.org/directory',
        'hash' => 'aHR0cHM6Ly9hY21lLXN0YWdpbmcuYXBpLmxldHNlbmNyeXB0Lm9yZy9kaXJlY3RvcnkK'
      },
      'v2-production' => {
        'url'  => 'https://acme-v02.api.letsencrypt.org/directory',
        'hash' => 'aHR0cHM6Ly9hY21lLXYwMi5hcGkubGV0c2VuY3J5cHQub3JnL2RpcmVjdG9yeQo'
      },
      'v2-staging'    => {
        'url'  => 'https://acme-staging-v02.api.letsencrypt.org/directory',
        'hash' => 'aHR0cHM6Ly9hY21lLXN0YWdpbmctdjAyLmFwaS5sZXRzZW5jcnlwdC5vcmcvZGlyZWN0b3J5Cg'
      },
    }
    $dh_param_size = 2048
    $manage_packages = true
    $manage_user = true
    $user = 'letsencrypt'
    $group = 'letsencrypt'
}
