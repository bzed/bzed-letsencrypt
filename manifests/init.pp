# == Class: letsencrypt
#
# Full description of class letsencrypt here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'letsencrypt':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class letsencrypt (
    $domains = [],
    $letsencrypt_sh_git_url = 'https://github.com/lukas2511/letsencrypt.sh.git',
    $challengetype = 'dns-01',
    $hook_source = undef,
    $hook_content = undef
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
        require => Group['letsencrypt']
    }

    file { $::letsencrypt::params::base_dir :
    }
    file { $::letsencrypt::params::csr_dir :
    }
    file { $::letsencrypt::params::key_dir :
        mode    => '0750',
    }

    if ($::fqdn == $::puppetmaster) {
        if not ($hook_source or $hook_content) {
            fail('$hook_source or $hook_content needs to be specified!')
        }
        class { '::letsencrypt::request::handler' :
            letsencrypt_sh_git_url => $letsencrypt_sh_git_url,
            hook_source            => $hook_source,
            hook_content           => $hook_content
        }
    }


    letsencrypt::deploy { $domains :
    }
    letsencrypt::csr { $domains :
    }

}
