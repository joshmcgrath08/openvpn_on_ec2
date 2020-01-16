# Summary

This repository allows __anyone__ to create and maintain their own VPN (using the open source version of [OpenVPN](https://en.wikipedia.org/wiki/OpenVPN)) on AWS in under __15 minutes__ and a dozen clicks for as little as __$2/month__. No technical background is required or expected.

For more about what a VPN is and why you might want to use one, [this post on Hackernoon](https://hackernoon.com/why-you-should-be-using-a-vpn-in-2019-63ui3y83) is pretty good.

For more information about cost and technical details, refer to the [details section](#details).

[![Launch Now](https://www.dl.dropboxusercontent.com/s/ue3ex9c9w7fnkqf/openvpn_on_ec2_launch_icon.png?dl=0)](https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=PersonalVPN&templateURL=https://s3.amazonaws.com/openvpn-on-ec2-cfn-templates-public/cf_template.json)

## Setup

Instructions are provided both in the form of screenshots and more detailed text.

### Visual Instructions

<table>

<thead>
<tr>
<th>1: Click "Launch Now"</th>
<th>2: Log in (create account if needed)</th>
<th>3: Click "Next"</th>
</tr>
</thead>

<thead>
<tr>
<th><img src="https://www.dl.dropboxusercontent.com/s/hp52b6pn2dvzor3/openvpn_on_ec2_screenshot_1.jpg?dl=0" width="250"/></th>
<th><img src="https://www.dl.dropboxusercontent.com/s/sl2oezcs2t01lxk/openvpn_on_ec2_screenshot_2.jpg?dl=0" width="250"/></th>
<th><img src="https://www.dl.dropboxusercontent.com/s/xoawwrud7covsqu/openvpn_on_ec2_screenshot_3.jpg?dl=0" width="250"/></th>
</tr>
</thead>

<thead>
<tr>
<th>4: Click "Next" two more times</th>
<th>5: Acknolwedge and click<br/>"Create Stack"</th>
<th>6: Click "Stack Info"</th>
</tr>
</thead>

<thead>
<tr>
<th><img src="https://www.dl.dropboxusercontent.com/s/2ivq4ady6rhhgtr/openvpn_on_ec2_screenshot_4.jpg?dl=0" width="250"/></th>
<th><img src="https://www.dl.dropboxusercontent.com/s/uytmpd4vpfdf8lt/openvpn_on_ec2_screenshot_5.jpg?dl=0" width="250"/></th>
<th><img src="https://www.dl.dropboxusercontent.com/s/7351muq54liwc51/openvpn_on_ec2_screenshot_6.jpg?dl=0" width="250"/></th>
</tr>
</thead>

<thead>
<tr>
<th>7: Refresh until Status is<br/>"CREATE_COMPLETE"<br/>(about 5-10 minutes)</th>
<th>8: Click "Outputs"</th>
<th>9: Click the<br/>"ClientConfigurationUrl" link</th>
</tr>
</thead>

<thead>
<tr>
<th><img src="https://www.dl.dropboxusercontent.com/s/h1g4cahg9mr7b3p/openvpn_on_ec2_screenshot_7.jpg?dl=0" width="250"/></th>
<th><img src="https://www.dl.dropboxusercontent.com/s/2n4a0qxbsiykkuc/openvpn_on_ec2_screenshot_8.jpg?dl=0" width="250"/></th>
<th><img src="https://www.dl.dropboxusercontent.com/s/6nh6b9skruhkfjb/openvpn_on_ec2_screenshot_9.jpg?dl=0" width="250"/></th>
</tr>
</thead>

<thead>
<tr>
<th>10: Click "Download" and<br/>save the client key</th>
<th>11: Import the key into<br/>OpenVPN Connect</th>
<th>12: You're connected</th>
</tr>
</thead>

<thead>
<tr>
<th><img src="https://www.dl.dropboxusercontent.com/s/jfn4fl3pq9dn2oq/openvpn_on_ec2_screenshot_10.jpg?dl=0" width="250"/></th>
<th><img src="https://www.dl.dropboxusercontent.com/s/rkm29npry6vj2mz/openvpn_on_ec2_screenshot_11.jpg?dl=0" width="250"/></th>
<th><img src="https://www.dl.dropboxusercontent.com/s/05gnges7p4loeou/openvpn_on_ec2_screenshot_12.jpg?dl=0" width="250"/></th>
</tr>
</thead>

</table>

### Text Instructions

1. Click the "Launch Now" icon above
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
    1. If you don't see "Create stack" at the top of the screen after logging in, click the "Launch Now" icon again
    1. On the "Create stack" screen, click the orange "Next" button in the bottom right
    1. On the "Specify stack details" screen, again click the orange "Next" button
    1. On the "Configure stack options" screen, again click the orange "Next" button
    1. On the "Review" screen, scroll down to the bottom and check the box in the blue box with the title "The following resource(s) require capabilities: [AWS::IAM::Role]". This indicates that in the process of creating the VPN, a new role (which grants permissions) will be created in your account and provided to the VPN
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
    1. Open the OpenVPN Connect client
    1. Import the client key you downloaded earlier
    1. With a few more clicks, you should be connected

# Details

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

By default, spot instances are used as they are significantly cheaper. On the other hand, on-demand instances are eligible for the free tier and have better availability guarantees. It would not be difficult to change the Cloudformation template to allow for on-demand instances as well.

## Testing

Travis runs an end-to-end test to ensure VPNs can be set up and used to access the internet

[![Build Status](https://travis-ci.org/joshmcgrath08/openvpn_on_ec2.svg?branch=master)](https://travis-ci.org/joshmcgrath08/openvpn_on_ec2)

Additional security and client testing should be done.

## Cost

In addition to the cost of the EC2 spot instance itself (based on market price), there are costs for storage (about $0.80/month), and network (about $0.10/GB/month).
