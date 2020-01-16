# Summary

[![Build Status](https://travis-ci.org/joshmcgrath08/openvpn_on_ec2.svg?branch=master)](https://travis-ci.org/joshmcgrath08/openvpn_on_ec2)

This repository allows __anyone__ to create and maintain their own private VPN (using the open source version of [OpenVPN](https://en.wikipedia.org/wiki/OpenVPN)) on AWS for about __$1.25/month__ in under __15 minutes__ and a dozen clicks. You do not need any technical background. The instructions below and process are intended for a wide audience.

There are numerous blog posts that describe in great technical detail how to set everything up by hand, but it's a fairly lengthy, error-prone, and technical process. Instead, I (and I expect others) just want a cheap, reliable VPN that works, which is why I've automated the process of setting up the VPN that I have been using. While the steps below may appear lengthy at first, that is only for completeness. It does not represent the complexity or time of the process.

## Setup

The following steps should take about 10-15 minutes to execute

1. Click [this link](https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=PersonalVPN&templateURL=https://s3.amazonaws.com/openvpn-on-ec2-cfn-templates-public/cf_template.json)
1. Sign in to AWS
    1. If you already have an AWS account, sign in
    1. If you do not already have an AWS account
        1. Click the grey "Create a new AWS account" button
        1. Enter your email, password, and whatever you want for an account name (e.g. "personal account")
        1. Click the gold "Continue" button
        1. Select the appropriate account type (likely "Personal")
        1. Enter your personal information
        1. Click the "Create Account and Continue" button
        1. Enter your credit card and billing address
        1. Click the "Verify and Add" button
        1. Verify your identity via SMS or voice call
        1. Select the "Basic Plan"
        1. Click the gold "Sign in to the Console" button
        1. Sign in using the email/password you used above
1. Create your VPN via Cloudformation
    1. If you don't see "Create stack" at the top of the screen after logging in, click [this link](https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=PersonalVPN&templateURL=https://s3.amazonaws.com/openvpn-on-ec2-cfn-templates-public/cf_template.json) again
    1. On the "Create stack" screen, click the orange "Next" button in the bottom right
    1. On the "Specify stack details" screen, again click the orange "Next" button
    1. On the "Configure stack options" screen, again click the orange "Next" button
    1. On the "Review" screen, scroll down to the bottom and check the box in the blue box with the title "The following resource(s) require capabilities: [AWS::IAM::Role]". This indicates that in the process of creating the VPN, a new role (which grants permissions) will be created in your account and provided to the VPN to allow it to function
    1. Click the orange "Create stack" button
    1. Select the "Stack info" tab and observe the "Status" field says "CREATE_IN_PROGRESS"
    1. When the "Status" field changes to "CREATE_COMPLETE" (may require refreshing), click the "Outputs" tab. This usually takes 5-10 minutes
       1. Click the link in the "Value" field in the "Output" tab. This will open S3, which is storing the key you'll use to access your VPN
    1. Click the "Download" button, and save the client key to your computer. Keep in mind that this file behaves like a password for your VPN, so keep it safe
4. Download and install the appropriate OpenVPN Connect client
    - [Windows](https://openvpn.net/client-connect-vpn-for-windows/)
    - [OS X](https://openvpn.net/vpn-server-resources/connecting-to-access-server-with-macos/#Download_the_OpenVPN_Connect_Client)
    - [iOS](https://apps.apple.com/us/app/openvpn-connect/id590379981)
    - [Android](https://play.google.com/store/apps/details?id=net.openvpn.openvpn&hl=en_US)
5. Connect your client to the VPN server
    - Open the OpenVPN Connect client
    - Select the "File" tab
    - Import the client key you downloaded earlier
    - With a few more clicks, you should be connected

# Technical details

## Cloudformation

Cloudformation is used in order to provision all of the resources (EC2 for running the VPN, S3 for storing the generated client key, etc.) in your own AWS account.

### Generating AMI ids

AMI ids vary by region, and only Amazon Linux supports the "latest" functionality. The list of AMI ids in the Cloudformation template were produced with the following steps:

1. Visit [this awesome website](https://cloud-images.ubuntu.com/locator/ec2/)
2. Filter to Ubuntu 18.04 LTS, AMD64 architecture
3. Run the following in the JS console and paste the output:

```javascript
copy([...document.querySelectorAll("tr.odd, tr.even")].map(x => "{\"" + x.cells[0].textContent + "\": {\"HVM64\": \"" + x.cells[6].textContent + "\"}}").join(",\n"))
```

## Keeping Ubuntu up-to-date

Automatic updates are configured with the following code from `./setup_ec2.sh`:

```sh
# Configure unattended upgrades for Ubuntu
apt-get install unattended-upgrades update-notifier-common --assume-yes
dpkg-reconfigure --frontend noninteractive --priority=low unattended-upgrades
AUC=/etc/apt/apt.conf.d/20auto-upgrades
echo "APT::Periodic::Verbose \"1\";" >> "$AUC"
echo "Unattended-Upgrade::Automatic-Reboot \"true\";" >> "$AUC"
```

## EC2 Instances

By default, spot instances are used as they are significantly cheaper. On the other hand, on-demand instances are eligible for the free tier. It would not be difficult to change the Cloudformation template to allow for on-demand instances as well.

## Testing

While provisioning, connecting to, and making requests through the VPN has been tested, including as part of the Travis CI tests, additional security testing should be performed.
