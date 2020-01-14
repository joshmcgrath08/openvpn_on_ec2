#!/bin/bash

set -eu

## Argument parsing

usage_and_exit() {
    echo "$0 (apply|revert|apply_revert)"
    exit 1
}

if [ $# != 1 ]
then
    usage_and_exit
elif [[ "$1" =~ ^(apply|revert|apply_revert)$ ]]
then
     DO_APPLY=false
     DO_REVERT=false
     if [ $1 == apply ]
     then
         DO_APPLY=true
     elif [ $1 == revert ]
     then
         DO_REVERT=true
     else
         DO_APPLY=true
         DO_REVERT=true
     fi
else
    usage_and_exit
fi

## Configure global vars

# Directory of this script
HERE=$(readlink -e $(dirname "$0"))
# Directory to store logs in
LOG_DIR=$(mktemp -d)
# Steps to execute in order
STEPS='install_new_pkgs setup_ca generate_ca_keys copy_keys_to_openvpn configure_openvpn_server configure_ip_forwarding configure_iptables enable_vpn'
# Dry run allows printing what would be executed without actually doing so
if [ -z "${DRY_RUN+x}" ]
then
    DRY_RUN=false
fi
# For development purposes, allows just the last step to be run
if [ -z "${RUN_LAST_ONLY+x}" ]
then
    RUN_LAST_ONLY=false
fi

## Main function

run() {
    if [ $DO_APPLY == true ]
    then
        for c in $(get_steps)
        do
            run_cmd_and_report "${c}_apply" "Applying $c"
        done
    fi

    if [ $DO_REVERT == true ]
    then
        for c in $(get_steps | tac -s ' ')
        do
            run_cmd_and_report "${c}_revert" "Reverting $c"
        done
    fi
}

## Helper functions

get_steps() {
    if [ "$RUN_LAST_ONLY" == true ]
    then
        echo $STEPS | tr ' ' '\n' | tail -n 1
    else
        echo $STEPS
    fi
}

run_cmd_and_report() {
    cmd="$1"
    msg="$2"
    log_file="${LOG_DIR}/${cmd}.log"
    start_time=$(date +%s)
    if [ "$DRY_RUN" == false ]
    then
        set +e
        "$cmd" 2>&1 > "$log_file"
        res=$?
        set -e
    else
        res=0
    fi

    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m'
    if [ $res == 0 ]
    then
        prefix="${GREEN}[SUCCESS]${NC}"
    else
        prefix="${RED}[FAILURE]${NC}"
    fi
    end_time=$(date +%s)
    echo -e "$prefix $msg ($(( end_time - start_time ))s)"
    if [ $res != 0 ]
    then
        tail -n 25 "$log_file"
        echo "For more information, refer to $log_file"
    fi
    return $res
}

## Functions for individual steps

install_new_pkgs_apply() {
    apt-get update && apt-get install openvpn easy-rsa --assume-yes
}

install_new_pkgs_revert() {
    apt-get purge openvpn easy-rsa --assume-yes
}

setup_ca_apply() {
    mkdir -p /etc/openvpn/easy-rsa
    cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa

    sed -i 's/export KEY_CONFIG=/#export KEY_CONFIG=/' /etc/openvpn/easy-rsa/vars
    cat <<EOF >> /etc/openvpn/easy-rsa/vars
export KEY_COUNTRY="US"
export KEY_PROVINCE="MA"
export KEY_CITY="Boston"
export KEY_ORG="PersonalVpnOrg"
export KEY_EMAIL="nosuchemail@no.such.domain.com"
export KEY_CN=PersonalVpn
export KEY_ALTNAMES=PersonalVpnAltName
export KEY_NAME=PersonalVpn
export KEY_OU=PersonalVpn
export KEY_CONFIG=`find /etc/openvpn/easy-rsa/ -type f -name 'openssl*.cnf' | sort -r | head -n 1`
EOF
}

setup_ca_revert() {
    rm -rf /etc/openvpn/easy-rsa
}

generate_ca_keys_apply() {
    cd /etc/openvpn
    rm -f *.ovpn
    cd /etc/openvpn/easy-rsa
    source vars
    ./clean-all
    ./pkitool --initca
    {
        # Accept the proposed values 10 times
        echo -en "\n\n\n\n\n\n\n\n\n\n"
        # Sleep to wait for next prompt (otherwise this breaks)
        sleep 1
        # Sign the certificate and commit
        echo -en "y\ny\n"
    } | ./build-key-server server
    ./build-dh
    openvpn --genkey --secret keys/ta.key
}

generate_ca_keys_revert() {
    rm -rf /etc/openvpn/easy-rsa/keys
}

copy_keys_to_openvpn_apply() {
    cd /etc/openvpn/easy-rsa/keys
    cp server.crt server.key ca.crt dh2048.pem ta.key /etc/openvpn
}

copy_keys_to_openvpn_revert() {
    cd /etc/openvpn
    rm -f server.crt sever.key ca.crt dh2048.pem ta.key
}

configure_openvpn_server_apply() {
    # ca, cert, key, and dh have already been named consistently with
    # the default openvpn config, so there's no need to update those
    # values in the config file here
    cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
    gzip -df /etc/openvpn/server.conf.gz
    # Config file does not end with a newline, so we begin by appending one
    echo "" >> /etc/openvpn/server.conf
    sed -ir 's/^;user nobody$/user nobody/' /etc/openvpn/server.conf
    sed -ir 's/^;group nobody$/group nogroup/' /etc/openvpn/server.conf
    sed -ir 's/^verb [0-9]$/verb 6/' /etc/openvpn/server.conf
    echo "push \"redirect-gateway def1 bypass-dhcp\"" >> /etc/openvpn/server.conf
    echo "push \"dhcp-option DNS 8.8.8.8\"" >> /etc/openvpn/server.conf
    echo "push \"dhcp-option DNS 8.8.4.4\"" >> /etc/openvpn/server.conf
}

configure_openvpn_server_revert() {
    rm -f /etc/openvpn/server.conf.gz /etc/openvpn/server.conf
}

SYSCTL_CONF='/etc/sysctl.conf'
configure_ip_forwarding_apply() {
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' "$SYSCTL_CONF"
    sysctl -p "$SYSCTL_CONF"
}

configure_ip_forwarding_revert() {
    sed -i 's/net.ipv4.ip_forward=1/#net.ipv4.ip_forward=1/' "$SYSCTL_CONF"
    sysctl -p "$SYSCTL_CONF"
}

ETHER_DEVICE=$(ip link show | grep -B 1 'link/ether' | head -n 1 | awk '{print $2}' | tr -d ':')
configure_iptables_apply() {
    iptables -t nat -A POSTROUTING -o "$ETHER_DEVICE" -j MASQUERADE
}

configure_iptables_revert() {
    iptables -t nat -D POSTROUTING -o "$ETHER_DEVICE" -j MASQUERADE || true
}

enable_vpn_apply() {
    systemctl enable openvpn@server
    systemctl start openvpn@server
}

enable_vpn_revert() {
    set +e
    systemctl status openvpn@server
    status_res=$?
    set -e

    if [ $status_res == 0 ]
    then
        systemctl disable openvpn@server
    fi
}

run
