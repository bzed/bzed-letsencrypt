# Define: letsencrypt::request::crt
#
# Take certificates form facter and export a ressource
# with the certificate content.
#

define letsencrypt::request::crt(
    $domain = $name
) {

    $handler_requests_dir = $::letsencrypt::handler_requests_dir
    $base_dir             = "${handler_requests_dir}/${domain}"
    $crt_file             = "${base_dir}/${domain}.crt"
    $ocsp_file            = "${base_dir}/${domain}.crt.ocsp"
    $crt_chain_file       = "${base_dir}/${domain}_ca.pem"

    $crt = file($crt_file)

    # special handling for ocsp stuff - binary junk...
    $ocsp = base64('encode', file_or_empty_string($ocsp_file))

    $crt_chain = file_or_empty_string($crt_chain_file)

    if ($crt =~ /BEGIN CERTIFICATE/) {
        @@letsencrypt::deploy::crt { $domain :
            crt_content       => $crt,
            crt_chain_content => $crt_chain,
            ocsp_content      => $ocsp,
            tag               => $::fqdn,
        }
    }
}
