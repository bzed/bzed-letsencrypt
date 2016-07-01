# == Class: letsencrypt
#
# Include this class if you would like to create
# Certificates or on your puppetmaster to have you CSRs signed.
#
#
# === Parameters
#
# [*domains*]
#   Array of full qualified domain names (== commonname)
#   you want to request a certificate for.
#   For SAN certificates you need to pass space seperated strings,
#   for example ['foo.example.com fuzz.example.com', 'blub.example.com']
#
# [*letsencrypt_sh_git_url*]
#   URL used to checkout the letsencrypt.sh using git.
#   Defaults to the upstream github url.
#
# [*channlengetype*]
#   Challenge type to use, default is 'dns-01'. Your letsencrypt.sh
#   hook needs to be able to handle it.
#
# [*hook_source*]
#   Points to the source of the letsencrypt.sh hook you'd like to
#   distribute ((as in file { ...: source => })
#   hook_source or hook_content needs to be specified.
#
# [*hook_content*]
#   The actual content (as in file { ...: content => }) of the
#   letsencrypt.sh hook.
#   hook_source or hook_content needs to be specified.
#
# [*letsencrypt_host*]
#   The host you want to run letsencrypt.sh on.
#   For now it needs to be a puppetmaster, as it needs direct access
#   to the certificates using functions in puppet.
#
# [*letsencrypt_ca*]
#   The letsencrypt CA you want to use. For debugging you want to
#   set it to 'https://acme-staging.api.letsencrypt.org/directory'
#
# [*letsencrypt_contact_email*]
#   E-mail to use during the letsencrypt account registration.
#   If undef, no email address is being used.
#
# [*letsencrypt_proxy*]
#   Proxyserver to use to connect to the letsencrypt CA
#   for example '127.0.0.1:3128'
#
# [*dh_param_size*]
#   dh parameter size, defaults to 2048
#
# === Examples
#   class { 'letsencrypt' :
#       domains     => [ 'foo.example.com', 'fuzz.example.com' ],
#       hook_source => 'puppet:///modules/mymodule/letsencrypt_sh_hook'
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
class letsencrypt (
    $domains = [],
    $letsencrypt_sh_git_url = 'https://github.com/lukas2511/letsencrypt.sh.git',
    $challengetype = 'dns-01',
    $hook_source = undef,
    $hook_content = undef,
    $letsencrypt_host = undef,
    $letsencrypt_ca = 'https://acme-v01.api.letsencrypt.org/directory',
    $letsencrypt_contact_email = undef,
    $letsencrypt_proxy = undef,
    $dh_param_size = 2048,
){

    require ::letsencrypt::params
    require ::letsencrypt::setup

    $letsencrypt_real_host = pick(
        $letsencrypt_host,
        $::servername,
        $::puppetmaster
    )

    if ($::fqdn == $letsencrypt_real_host) {
        require ::letsencrypt::setup::puppetmaster

        if !($hook_source or $hook_content) {
            notify { '$hook_source or $hook_content needs to be specified!' :
                loglevel => err,
            }
        } else {
            class { '::letsencrypt::request::handler' :
                letsencrypt_sh_git_url    => $letsencrypt_sh_git_url,
                letsencrypt_ca            => $letsencrypt_ca,
                hook_source               => $hook_source,
                hook_content              => $hook_content,
                letsencrypt_contact_email => $letsencrypt_contact_email,
                letsencrypt_proxy         => $letsencrypt_proxy,
            }
        }
        if ($::letsencrypt_crts and $::letsencrypt_crts != '') {
            $letsencrypt_crts_array = split($::letsencrypt_crts, ',')
            ::letsencrypt::request::crt { $letsencrypt_crts_array : }
        }
    }


    ::letsencrypt::certificate { $domains :
        letsencrypt_host => $letsencrypt_real_host,
        challengetype    => $challengetype,
        dh_param_size    => $dh_param_size,
    }


}
