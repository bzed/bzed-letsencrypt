#!/bin/bash

sed -e
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if [ $# -ne 2 ]; then exit 255; fi

# exit if both files exist and the chain file is more recent.
if [ -r "${1}" -a -r "${2}" ]; then
    if [ $(stat -c '%Y' "${1}") -le $(stat -c '%Y' "${2}") ]; then
        exit 0
    fi
fi

CHAINURL=$(openssl x509 -in "${1}" -noout -text | grep 'CA Issuers - URI:' | cut -d':' -f2-)
wget -q -O "${2}.new"
if ! grep -q "BEGIN CERTIFICATE" "${2}.new"; then
    openssl x509 -in "${2}.new" -inform DER -out "${2}.new" -outform PEM
fi
mv "${2}.new" "${2}"

