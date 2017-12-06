## Release 0.1.17
###Summary

- Last bugfix release before the module will be renamed to bzed-dehydrated.

####Bugfixes

- Rubocop / travis-ci fixes
- Inherit class params from params.pp

## Release 0.1.16
###Summary

- letsencrypt.sh was renamed to dehydrated. This release makes bzed-letsencrypt work with dehydrated while staying compatible as much as possible.
- I'll follow the rename - bzed-letsencrypt will be renamed to bzed-dehydrated before somebody tries to force me to do so. I understand that  Let’s Encrypt™ needs to enforce their trademark, but they should find a better way to handle these issues.

####Features

- Use 'dehydrated'.

####Bugfixes

- Various little bugfixes


## Release 0.1.15
###Summary

- Bugfix release
- Better Puppetserver support

####Bugfixes

  - Various minor bugfixes, typo fixes.

####Improvements

 - Better variable validation
 - Use puppetserver variables automatically


## Release 0.1.14
###Summary

- Introduce letsencrypt::certificate

####Improvements

- With the new letsencrypt::certificate it is now possible to request certificates from other puppet modules. Subscribing to the define or receiving notifications from it is also possible.
- Add an usage example to README.md, showing how to use letsencrypt::certificate with camptocamp-postfix.

## Release 0.1.13
###Summary

- Bugfix-only release.

####Bugfixes

- Don't require User['letsencrypt'] on clients - its only available on puppet masters.

## Release 0.1.12
###Summary

- Avoid dh parameter generation on the puppet master host.

####Bugfixes

- Add missing dependency on puppetlabs-vcsrepo.

####Improvements

- Create dh files on the puppet client, not master. Made possible by requiring an uptodate concat version.

## Release 0.1.11
###Summary

- Bugfix-only release.

####Bugfixes

- Ensure we're compatible to older releases.
- Remove some unused code.

## Release 0.1.10
###Summary

- The 'OCSP' release.

####Features

- Retrieve and ship OCSP stapling information into .crt.ocsp files.

####Bugfixes

- Remove old crt chain / dh files.

####Improvements

- Use file\_concat to build the full-key-chain file.


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
