#!/bin/bash

set -eux

HERE=$(dirname "$0")
S3_BUCKET_NAME="$1"
ELASTIC_IP="$2"
# This cannot be changed without also updating ./add_client.sh
# and cf_template.json
CLIENT_NAME='client'

apt-get update && apt-get install awscli --assume-yes

"${HERE}/setup_vpn.sh" apply
"${HERE}/add_client.sh" "$CLIENT_NAME" "$ELASTIC_IP"

S3_KEY="${CLIENT_NAME}.ovpn"

aws s3 cp "/etc/openvpn/${CLIENT_NAME}.ovpn" "s3://${S3_BUCKET_NAME}/${S3_KEY}"
