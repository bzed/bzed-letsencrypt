class letsencrypt::request::handler(
    $letsencrypt_sh_git_url
){

    require ::letsencrypt::params

    $handler_base_dir = $::letsencrypt::params::handler_base_dir
    $letsencrypt_sh_dir = $::letsencrypt::params::letsencrypt_sh_dir

    user { 'letsencrypt' :
        gid => 'letsencrypt'
    }

    File {
        owner => root,
        group => root
    }

    file { $handler_base_dir :
        ensure => directory,
        mode   => '0755'
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
