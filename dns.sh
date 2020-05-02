#!/bin/bash
set -o pipefail
set -u
DB=/tmp/dnsCache.db
touch "$DB"

function isInCache(){
    local dnsName="$1"
    grep -q -Fw "$dnsName" "$DB"
    return $?
}

function getFromCache(){
    local dnsName="$1"
    grep -Fw "$dnsName" "$DB" | cut -d , -f 2
    return $?
}

function getFromDNS(){
    local dnsName="$1"
    local ipAddress
    if ipAddress=$(dig +short "$dnsName" | grep -P '^\d'); then
        echo "$dnsName,$ipAddress" >> "$DB"
        echo "$ipAddress"
        return 0
    else
        return 1
    fi
}

read userInput
if isInCache "$userInput"; then
    getFromCache "$userInput"
    exit $?
else
    getFromDNS "$userInput"
    exit $?
fi
