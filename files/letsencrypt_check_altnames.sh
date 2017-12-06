#!/usr/bin/env bash

set -e
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CSR=${1}
CRT=${2}

declare -a CSR_DNS=($(openssl req -text -noout -in ${CSR} | awk '/DNS/ {print}' | sed s/,//g))
declare -a CRT_DNS=($(openssl x509 -text -noout -in ${CRT} -certopt no_subject,no_header,no_version,no_serial,no_signame,no_validity,no_subject,no_issuer,no_pubkey,no_sigdump,no_aux | awk '/DNS/ {print}' | sed s/,//g))
declare -a DIFF=()

OLD_IFS=$IFS
IFS=$'\n\t'

DIFF=($(comm -3 <(echo "${CSR_DNS[*]}" | sort -u) <(echo "${CRT_DNS[*]}" | sort -u)))
IFS=${OLD_IFS}

test  -z "${DIFF[*]}" || exit 1
exit 0
