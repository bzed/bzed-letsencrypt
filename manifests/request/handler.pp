class letsencrypt::request::handler(
    $letsencrypt_sh_git_url,
    $hook_source,
    $hook_content

){

    require ::letsencrypt::params

    $handler_base_dir    = $::letsencrypt::params::handler_base_dir
    $letsencrypt_sh_dir  = $::letsencrypt::params::letsencrypt_sh_dir
    $letsencrypt_sh_hook = $::letsencrypt::params::letsencrypt_sh_hook

    user { 'letsencrypt' :
        gid        => 'letsencrypt',
        home       => $handler_base_dir,
        shell      => '/bin/bash',
        managehome => false,
        password   => '!!'
    }

    File {
        owner => root,
        group => root
    }

    file { $handler_base_dir :
        ensure => directory,
        mode   => '0755'
    }

    file { $letsencrypt_sh_hook :
        ensure  => present,
        group   => 'letsencrypt',
        require => Group['letsencrypt'],
        source  => $hook_source,
        content => $hook_content,
        mode    => '0750'
    }

    vcsrepo { $letsencrypt_sh_dir :
        ensure   => latest,
        revision => master,
        provider => git,
        source   => $letsencrypt_sh_git_url,
        user     => root,
        require  => File[$handler_base_dir]
    }

    Letsencrypt::Request <<| tag == $::fqdn |>>
}
