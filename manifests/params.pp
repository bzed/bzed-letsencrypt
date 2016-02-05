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

    $letsencrypt_sh_dir  = "${handler_base_dir}/letsencrypt.sh"
    $letsencrypt_sh_hook = "${handler_base_dir}/letsencrypt_hook"
    $letsencrypt_sh      = "${letsencrypt_sh_dir}/letsencrypt.sh"

}
