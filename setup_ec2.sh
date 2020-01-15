#!/bin/bash

set -eux

HERE=$(dirname "$0")
S3_BUCKET_NAME="$1"
ELASTIC_IP="$2"
# This cannot be changed without also updating ./add_client.sh
# and cf_template.json
CLIENT_NAME='client'

# Configure VPN and generate client key
"${HERE}/setup_vpn.sh" apply
"${HERE}/add_client.sh" "$CLIENT_NAME" "$ELASTIC_IP"

# Install AWS CLI and upload client key to S3
apt-get update && apt-get install awscli --assume-yes
aws s3 cp "/etc/openvpn/${CLIENT_NAME}.ovpn" "s3://${S3_BUCKET_NAME}/${CLIENT_NAME}.ovpn"
rm -f "/etc/openvpn/${CLIENT_NAME}.ovpn"

# Configure unattended upgrades for Ubuntu
apt-get install unattended-upgrades update-notifier-common --assume-yes
dpkg-reconfigure --frontend noninteractive --priority=low unattended-upgrades
AUC=/etc/apt/apt.conf.d/20auto-upgrades
echo "APT::Periodic::Verbose \"1\";" >> "$AUC"
echo "Unattended-Upgrade::Automatic-Reboot \"true\";" >> "$AUC"
