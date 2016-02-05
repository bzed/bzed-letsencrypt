# Define: letsencrypt::request::crt
#
# Take certificates form facter and export a ressource
# with the certificate content.
#

define letsencrypt::request::crt(
    $domain = $name
) {

    require ::letsencrypt::params

    $handler_requests_dir = $::letsencrypt::params::handler_requests_dir
    $base_dir = "${handler_requests_dir}/${domain}"
    $crt_file = "${base_dir}/${domain}.crt"

    $crt = file($crt_file)
    if ($crt =~ /BEGIN CERTIFICATE/) {
        @@letsencrypt::deploy::crt { $domain :
            crt_content => $crt,
            tag         => $::fqdn,
        }
    }
}
