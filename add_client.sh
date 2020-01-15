#!/bin/bash

set -eu

HERE=$(dirname "$0")
KEY_DIR='/etc/openvpn'

usage_and_exit() {
    echo "$0 <client-name> <ip>"
    exit 1
}

if [ $# != 2 ]
then
    usage_and_exit
fi

CLIENT_NAME="$1"
IP="$2"

CLIENT_CONFIG="/etc/openvpn/${CLIENT_NAME}.ovpn"
if [ -f "$CLIENT_CONFIG" ]
then
    echo "\"$CLIENT_CONFIG\" already exists"
    echo "Please choose a different client name"
    exit 1
fi
touch "$CLIENT_CONFIG"
chmod 600 "$CLIENT_CONFIG"
chown ubuntu "$CLIENT_CONFIG"

cat <<EOF >> "$CLIENT_CONFIG"
client
dev tun
proto udp
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
verb 3
key-direction 1
redirect-gateway def1
EOF

echo "remote $IP 1194" >> "$CLIENT_CONFIG"

echo '<ca>' >> "$CLIENT_CONFIG"
cat "${KEY_DIR}/ca.crt" >> "${CLIENT_CONFIG}"
echo '</ca>' >> "$CLIENT_CONFIG"

cd /etc/openvpn/easy-rsa/
source vars
{
    # Accept the proposed values 10 times
    echo -en "\n\n\n\n\n\n\n\n\n\n"
    # Sleep to wait for next prompt (otherwise this breaks)
    sleep 1
    # Sign the certificate and commit
    echo -en "y\ny\n"
} | ./build-key "$CLIENT_NAME"

echo '<cert>' >> "$CLIENT_CONFIG"
cat "${KEY_DIR}/${CLIENT_NAME}.crt" >> "${CLIENT_CONFIG}"
echo '</cert>' >> "$CLIENT_CONFIG"

echo '<key>' >> "$CLIENT_CONFIG"
cat "${KEY_DIR}/${CLIENT_NAME}.key" >> "${CLIENT_CONFIG}"
echo '</key>' >> "$CLIENT_CONFIG"

echo '<tls-auth>' >> "$CLIENT_CONFIG"
cat "${KEY_DIR}/ta.key" >> "${CLIENT_CONFIG}"
echo '</tls-auth>' >> "$CLIENT_CONFIG"

rm -f /etc/openvpn/easy-rsa/keys/${CLIENT_NAME}*

echo "Generated client certificate: \"$CLIENT_CONFIG\""
