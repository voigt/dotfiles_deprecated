#!/bin/bash

cf_auth_email=$CF_AUTH_EMAIL
cf_api_key=$CF_API_KEY
cf_zone_name=$CF_ZONE_NAME
DO_IP=$1

function set_cf_dns_record {
    record_name="$1"
    type="$2"
    ip="$3"

    zone_identifier=$(
        curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$cf_zone_name" \
        -H "X-Auth-Email: $cf_auth_email" \
        -H "X-Auth-Key: $cf_api_key" \
        -H "Content-Type: application/json" | jq -r '.result[0].id'
    )
    record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name" \
        -H "X-Auth-Email: $cf_auth_email" \
        -H "X-Auth-Key: $cf_api_key" \
        -H "Content-Type: application/json" | jq -r '.result[0].id'
    )

    if [[ $record_identifier == "null" ]]; then
        message="Create DNS Record for: $record_name -> ($type) $ip"
        echo -e "$message"
        result=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records" \
            -H "X-Auth-Email: $cf_auth_email" \
            -H "X-Auth-Key: $cf_api_key" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"$type\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":120,\"proxied\":false}")
        exit_code=0
    else
        message="Updating DNS Record to: $record_name -> ($type) $ip"
        echo -e "$message"
        result=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
            -H "X-Auth-Email: $cf_auth_email" \
            -H "X-Auth-Key: $cf_api_key" \
            -H "Content-Type: application/json" \
            --data "{\"id\":\"$zone_identifier\",\"type\":\"$type\",\"name\":\"$record_name\",\"content\":\"$ip\"}")
        exit_code=0
    fi

    if [[ $(echo $result | jq -r '.success') != true ]]; then
        message="DNS update failed for $record_name. Dumping results:\n$result"
        echo -e "$message"
        exit_code=1
    else
        message="Successfully set DNS entries for $record_name."
        echo -e "$message"
        exit_code=0
    fi
}

set_cf_dns_record "workstation.christophvoigt.com" "A" "$DO_IP"
exit $((exit_code))