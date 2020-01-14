#!/bin/bash

set -eux

HERE=$(dirname "$0")
S3_BUCKET_NAME="$1"
SNS_TOPIC_ARN="$2"
ELASTIC_IP="$3"
AWS_REGION="$4"
CLIENT_NAME='client'

apt-get update && apt-get install awscli --assume-yes

"${HERE}/setup_vpn.sh" apply
"${HERE}/add_client.sh" "$CLIENT_NAME" "$ELASTIC_IP"

S3_KEY="${CLIENT_NAME}.ovpn"
S3_CONSOLE_URL='https://s3.console.aws.amazon.com/s3/object'

aws s3 cp "/etc/openvpn/${CLIENT_NAME}.ovpn" "s3://${S3_BUCKET_NAME}/${S3_KEY}"

aws --region "$AWS_REGION" sns publish --topic-arn "$SNS_TOPIC_ARN" --subject "Your new VPN key" \
    --message "Download key here (requires logging in to AWS): ${S3_CONSOLE_URL}/${S3_BUCKET_NAME}/${S3_KEY}"
