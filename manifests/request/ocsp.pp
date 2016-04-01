# Define: letsencrypt::request::ocsp
#
# Retrieve ocsp stapling information
#

define letsencrypt::request::ocsp(
    $domain = $name
) {

    require ::letsencrypt::params

    $handler_requests_dir = $::letsencrypt::params::handler_requests_dir
    $base_dir             = "${handler_requests_dir}/${domain}"
    $crt_file             = "${base_dir}/${domain}.crt"
    $crt_chain_file       = "${base_dir}/${domain}_ca.pem"
    $ocsp_file            = "${crt_file}.ocsp"
    $letsencrypt_ocsp_request = $::letsencrypt::params::letsencrypt_ocsp_request

    $ocsp_command = join([
        $letsencrypt_ocsp_request,
        $crt_file,
        $crt_chain_file,
        $ocsp_file,
    ], ' ')
    $ocsp_onlyif = join([
        '/usr/bin/test',
        '-f',
        "'${crt_file}'",
    ], ' ')

    $ocsp_unless = join([
        '/usr/bin/test',
        '-f',
        "'${ocsp_file}'",
        '&&',
        '/usr/bin/test',
        '$(',
        "/usr/bin/stat -c '%Y' ${ocsp_file}",
        ')',
        '-gt',
        '$(',
        "/bin/date --date='1 day ago' '+%s'",
        ')',
    ], ' ')

    exec { "update_ocsp_file_for_${domain}" :
        command => $ocsp_command,
        unless  => $ocsp_unless,
        onlyif  => $ocsp_onlyif,
        user    => letsencrypt,
        group   => letsencrypt,
        require => File[$letsencrypt_ocsp_request],
    }

    file { $ocsp_file :
        mode    => '0644',
        replace => false,
        require => Exec["update_ocsp_file_for_${domain}"],
    }

}
