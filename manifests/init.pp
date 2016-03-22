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
    $letsencrypt_host = $::puppetmaster,
    $letsencrypt_ca = 'https://acme-v01.api.letsencrypt.org/directory',
){

    require ::letsencrypt::params

    group { 'letsencrypt' :
        ensure => present,
    }

    File {
        ensure  => directory,
        owner   => 'root',
        group   => 'letsencrypt',
        mode    => '0755',
        require => Group['letsencrypt'],
    }

    file { $::letsencrypt::params::base_dir :
    }
    file { $::letsencrypt::params::csr_dir :
    }
    file { $::letsencrypt::params::crt_dir :
    }
    file { $::letsencrypt::params::key_dir :
        mode    => '0750',
    }

    if ($::fqdn == $letsencrypt_host) {
        if !($hook_source or $hook_content) {
            notify { '$hook_source or $hook_content needs to be specified!' :
                loglevel => err,
            }
        } else {
            class { '::letsencrypt::request::handler' :
                letsencrypt_sh_git_url => $letsencrypt_sh_git_url,
                letsencrypt_ca         => $letsencrypt_ca,
                hook_source            => $hook_source,
                hook_content           => $hook_content,
            }
        }
        if ($::letsencrypt_crts and $::letsencrypt_crts != '') {
            $letsencrypt_crts_array = split($::letsencrypt_crts, ',')
            letsencrypt::request::crt { $letsencrypt_crts_array : }
        }
    }


    letsencrypt::deploy { $domains :
        letsencrypt_host => $letsencrypt_host,
    }
    letsencrypt::csr { $domains :
        letsencrypt_host => $letsencrypt_host,
        challengetype    => $challengetype,
    }

}
