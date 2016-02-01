define letsencrypt::deploy(
    $domain = $name
) {

    Letsencrypt::Deploy::Crt <<| domain == $domain and tag == $::puppetmaster |>>

}
