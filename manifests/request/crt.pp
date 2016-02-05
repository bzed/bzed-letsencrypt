# Define: letsencrypt::request::crt
#
# Take certificates form facter and export a ressource
# with the certificate content.
#

define letsencrypt::request::crt(
    $domain = $name
) {

    $crt = getvar("::letsencrypt_crt_${domain}")
    if ($crt) {
        @@letsencrypt::deploy::crt { $domain :
            crt_content => $crt,
            tag         => $::fqdn,
        }
    }
}
