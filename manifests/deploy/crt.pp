# = Define: letsencrypt::crt
#
# Used as exported ressource to ship a signed CRT.
#
# == Parameters:
#
# [*crt_file*]
#   File which contains the crt.
#
# [*domain*]
#   Certificate commonname / domainname.
#

define letsencrypt::deploy::crt(
    $crt_file,
    $domain = $name
) {

    require ::letsencrypt::params

    $handler_requests_dir = $::letsencrypt::params::handler_requests_dir
    $base_dir = "${handler_requests_dir}/${domain}"
    $crt      = "${base_dir}/${domain}.crt"


    file { $crt :
        ensure  => file,
        owner   => root,
        group   => letsencrypt,
        content => file($crt_file),
        mode    => '0644',
    }
}
