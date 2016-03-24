## Release 0.1.9
###Summary

- The 'SAN-certificate' release.

####Features

- Allow to use http/https proxies with letsencrypt.sh
- Handle different letsencrypt CA URLs, useful for testing/debugging with
  the staging CA.
- Passing a contact email for the letsencrypt registration is possible now,
  too.

####Bugfixes
- Various minor bugs

####Improvements
- Fix various issues in the openssl certificate config file.
- Handle the private\_key.json file, keeping the registration
  information on disk.


## Release 0.1.8
###Summary

- Generate full chain .pem file, including the key.

## Release 0.1.7
###Summary

- Fixing typos / documentation.

## Release 0.1.6
###Summary

- Create .dh files

## Release 0.1.5
###Summary

- Fixing typos / documentation.

## Release 0.1.4
###Summary

- Add basic travis.ci checks
- Make rubocop and puppet-lint happy.

## Release 0.1.3
###Summary

- Actually deploy the ca chain certificate
- Add gitignore file.
- Fixing typos / documentation.

## Release 0.1.2
###Summary

- Fixing typos / documentation.
- Handle empty certificate chain files
- Various fixes

## Release 0.1.1
###Summary

- First working release.

<!--
## Release <version>
###Summary


####Features

####Bugfixes

####Improvements
-->
