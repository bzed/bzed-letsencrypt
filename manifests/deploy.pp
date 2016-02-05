# = Define: letsencrypt::deploy
#
# Collects signed certificates and installs them.
#
# == Parameters:
#
# [*letsencrypt_host*]
#   Host the certificates were signed on
#
# [*domain*]
#   Certificate commonname / domainname.
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


define letsencrypt::deploy(
    $letsencrypt_host,
    $domain = $name
) {

    Letsencrypt::Deploy::Crt <<| tag == $domain and tag == $letsencrypt_host |>>

}
