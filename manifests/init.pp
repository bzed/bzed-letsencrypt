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
# [*dehydrated_git_url*]
#   URL used to checkout the dehydrated using git.
#   Defaults to the upstream github url.
#
# [*channlengetype*]
#   Challenge type to use, default is 'dns-01'. Your dehydrated
#   hook needs to be able to handle it.
#
# [*hook_source*]
#   Points to the source of the dehydrated hook you'd like to
#   distribute ((as in file { ...: source => })
#   hook_source or hook_content needs to be specified.
#
# [*hook_content*]
#   The actual content (as in file { ...: content => }) of the
#   dehydrated hook.
#   hook_source or hook_content needs to be specified.
#
# [*hook_env*]
#   Additional environment variables to set when calling the
#   verification hook. For example, credentials can be passed
#   this way. This setting is optional.
#
# [*letsencrypt_host*]
#   The host you want to run dehydrated on.
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
# [*manage_packages*]
#   install necessary packages, mainly git
#
# === Examples
#   class { 'letsencrypt' :
#       domains     => [ 'foo.example.com', 'fuzz.example.com' ],
#       hook_source => 'puppet:///modules/mymodule/dehydrated_hook'
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
    $letsencrypt_sh_git_url = $::letsencrypt::params::letsencrypt_sh_git_url,
    $dehydrated_git_url = $letsencrypt_sh_git_url,
    $challengetype = $::letsencrypt::params::challengetype,
    $hook_source = undef,
    $hook_content = undef,
    $hook_env = $::letsencrypt::params::dehydrated_hook_env,
    $letsencrypt_host = $::letsencrypt::params::letsencrypt_host,
    $letsencrypt_ca = $::letsencrypt::params::letsencrypt_ca,
    $letsencrypt_cas = $::letsencrypt::params::letsencrypt_cas,
    $letsencrypt_contact_email = undef,
    $letsencrypt_proxy = undef,
    $dh_param_size = $::letsencrypt::params::dh_param_size,
    $manage_packages = $::letsencrypt::params::manage_packages,
) inherits ::letsencrypt::params {

    require ::letsencrypt::setup
    $letsencrypt_cas = $::letsencrypt::params::letsencrypt_cas

    if ($::fqdn == $letsencrypt_host) {
        class { '::letsencrypt::setup::puppetmaster' :
            manage_packages => $manage_packages,
        }

        if !($hook_source or $hook_content) {
            notify { '$hook_source or $hook_content needs to be specified!' :
                loglevel => err,
            }
        } else {
            class { '::letsencrypt::request::handler' :
                dehydrated_git_url        => $dehydrated_git_url,
                letsencrypt_ca            => $letsencrypt_ca,
                letsencrypt_cas           => $letsencrypt_cas,
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
        letsencrypt_host => $letsencrypt_host,
        challengetype    => $challengetype,
        dh_param_size    => $dh_param_size,
    }

}
