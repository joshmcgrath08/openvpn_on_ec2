# Summary

This repository contains a collection of scripts for automating the setup of OpenVPN on EC2 instances running Ubuntu.

# Cloudformation

## Generating AMI ids
Use [this awesome website](https://cloud-images.ubuntu.com/locator/ec2/), sorting to Ubuntu 18.04 LTS instances with AMD64 architecture, and the following JS:

```javascript
copy([...document.querySelectorAll("tr.odd, tr.even")].map(x => "{\"" + x.cells[0].textContent + "\": {\"HVM64\": \"" + x.cells[6].textContent + "\"}}").join(",\n"))
```
