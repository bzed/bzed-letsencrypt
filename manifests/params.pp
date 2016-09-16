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
    $csr_dir  = '/etc/letsencrypt/csr'
    $key_dir  = '/etc/letsencrypt/private'
    $crt_dir  = '/etc/letsencrypt/certs'

    $handler_base_dir = '/opt/letsencrypt'
    $handler_requests_dir  = "${handler_base_dir}/requests"

    $dehydrated_dir  = "${handler_base_dir}/dehydrated"
    $dehydrated_hook = "${handler_base_dir}/letsencrypt_hook"
    $dehydrated_conf = "${handler_base_dir}/letsencrypt.conf"
    $dehydrated      = "${dehydrated_dir}/dehydrated"

    $letsencrypt_chain_request = "${handler_base_dir}/letsencrypt_get_certificate_chain.sh"
    $letsencrypt_ocsp_request = "${handler_base_dir}/letsencrypt_get_certificate_ocsp.sh"
}
