define letsencrypt::deploy::crt(
    $crt_file,
    $domain = $name
) {

    require ::letsencrypt::params

    $handler_requests_dir = $::letsencrypt::params::handler_requests_dir
    $base_dir = "${handler_requests_dir}/${domain}"
    $crt_file = "${base_dir}/${domain}.crt"


    file { $crt_file :
        ensure  => file,
        owner   => root,
        group   => letsencrypt,
        content => file($crt_file),
        mode    => '0644',
    }
}
