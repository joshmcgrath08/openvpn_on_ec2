#!/bin/bash

set -eux

s3_key=''
stack_id=''

on_exit() {
    sudo killall -9 openvpn || true
    if [ "$s3_key" != '' ]
    then
        aws s3 rm "s3://${s3_key}"
    fi

    if [ "$stack_id" != '' ]
    then
        aws cloudformation delete-stack --stack-name "$stack_id"
    fi
}

trap on_exit EXIT

# create stack
stack_id=$(aws cloudformation create-stack --stack-name "OpenVpnOnEc2Test-$(uuidgen)" --tags 'Key=openvpn_on_ec2,Value=true' --parameters 'ParameterKey=InstanceType,ParameterValue=t3.nano' --template-body file://cf_template.json --capabilities CAPABILITY_IAM --query "StackId" --output text)

# wait up to 10 minutes for stack to be created
timeout 600s aws cloudformation wait stack-create-complete --stack-name "$stack_id"

# retrieve client ovpn file
s3_key=$(aws cloudformation describe-stacks --stack-name "$stack_id" --query 'Stacks[0].Outputs[0].OutputValue' --output text | sed 's/https:\/\/s3.console.aws.amazon.com\/s3\/object\///')
aws s3 cp "s3://${s3_key}" client.ovpn

# get IP of VPN from client ovpn file
vpn_ip=$(cat client.ovpn | egrep '^remote [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ [0-9]+$' | awk '{print $2}')

# get IP before configuring VPN
initial_ip=$(curl ifconfig.me/ip)

# start VPN using retrieved conf
sudo mv client.ovpn /etc/openvpn/client.conf
sudo systemctl start openvpn@client
sudo systemctl --no-pager status openvpn@client

# Wait a few seconds for VPN to be ready
sleep 5

# ensure we can ping the VPN
timeout 5s ping 10.8.0.1 -c 1

# use the google namesever (accessible from internet)
sudo mv /etc/resolv.conf /etc/resolv.conf.bak
echo "nameserver 8.8.8.8" > resolv.conf
sudo mv resolv.conf /etc/resolv.conf

# retrieve new IP (should be different)
new_ip=$(curl ifconfig.me/ip)

# verify old and new IPs are valid and different
if [[ ! $initial_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
  echo "Initial IP ($initial_ip) does not match regex"
  exit 1
elif [[ ! $new_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
  echo "New IP ($new_ip) does not match regex"
  exit 2
elif [ $initial_ip == $new_ip ]
then
  echo "Initial IP and new IP are the same ($initial_ip)"
  exit 3
elif [ $new_ip != $vpn_ip ]
then
    echo "New IP ($new_ip) and VPN IP ($vpn_ip) differ but shouldn't"
    exit 4
fi

# clean up
sudo systemctl stop openvpn@client
sudo systemctl disable openvpn@client
sudo rm /etc/openvpn/client.conf
sudo mv /etc/resolv.conf.bak /etc/resolv.conf

exit 0
