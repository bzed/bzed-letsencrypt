define letsencrypt::deploy(
    $letsencrypt_host,
    $domain = $name
) {

    Letsencrypt::Deploy::Crt <<| domain == $domain and tag == $letsencrypt_host |>>

}
