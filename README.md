# Packer Cookbook

- [Packer Cookbook](#packer-cookbook)
  - [Introduction](#introduction)
    - [Use Cases](#use-cases)
    - [Benefits](#benefits)
  - [Documentation](#documentation)
  - [Installation](#installation)
  - [Architecture](#architecture)
  - [Template Inspection](#template-inspection)
  - [Template Validation](#template-validation)
  - [Template Building](#template-building)
  - [Template Debugging](#template-debugging)

## Introduction

Packer automates the creation of customized images in a repeatable manner. It supports multiple platforms including AWS, Azure, GCP, Openstack, VMware, Docker.

### Use Cases

- Create Golden Images across platforms and environments
- Establishes an Image Factory Based on New Commits for Continous Delivery
- Automate Your Monthly Patching For New/Existing Workloads
- Create Immutable Infrastructure Using Packer in CI/CD Pipeline

### Benefits

- Version Controlled
- Consistent Images
- Automates Everything


## Documentation

- [Packer Landing Page](https://www.packer.io/)
- [Ubuntu Amazon EC2 AMI Locator](https://cloud-images.ubuntu.com/locator/ec2/)
- [Server Hardening Automation](https://dev-sec.io/)

## Installation

Packer is distributed as single binary. There are multiple ways how to download and install packer. Including the following options:
- Dowloading and storing precompiled binary (`wget`, `curl`)
- Installing from source
- Using system's default or custom package manager (`yum`, `apt`, `brew`, `chocolatey`)
- Running docker container (`docker container run -it hashicorp/packer:light`)

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer
```

## Architecture

Packer is written in Go language and compiled as single binary for various operating systems (Windows, Linux, macOS). It is modular and very extensible.

Packer builds images using a tempalte. Templates can be build using either `json` (old) or `hcl2` (recommended for v1.7.0+). 

Templates defines settings using blocks:
- Original Image to Use (source)
- Where to Build the Image (AWS, VMware, Openstack)
- Files to Upload to the Image (scripts, packages, certificates)
- Installation and Configuration of the Machine Image
- Data to Retrieve when Building

## Template Inspection

You can use the `packer inspect <template-file>` command to retrieve information about a template.

```json
Packer Inspect: JSON mode
Description:

Kibana Image

Optional variables and their defaults:

  client_id       = {{env `CLIENT_ID`}}
  client_secret   = {{env `CLIENT_SECRET`}}
  subscription_id = {{ env `SUBSCRIPTION_ID` }}

Builders:

  azure-arm

Provisioners:

  shell

Note: If your build names contain user variables or template
functions such as 'timestamp', these are processed at build time,
and therefore only show in their raw form here.
```


## Template Validation

You can use the `packer validate <template-file>` command to validate an existing template. For example a missing comma can result in the following error.

```json
Failed to parse file as legacy JSON template: if you are using an HCL template, check your file extensions; they should be either *.pkr.hcl or *.pkr.json; see the docs for more details: https://www.packer.io/docs/templates/hcl_templates. 
Original error: Error parsing JSON: invalid character '"' after object key:value pair
At line 6, column 10 (offset 133):
    5:         "instance_type": "t2.micro"
    6:         "
               ^

```


## Template Building

```bash
packer build ubuntu.json
```

Variables, can be defined inside the template, inside another file or loaded from system variables.

```bash
export AWS_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXX
export AWS_SECRET_KEY=YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
export AWS_REGION=eu-north-1
```

```json
{
  "variables": {
    "aws_access_key": "{{env `AWS_ACCESS_KEY`}}",
    "aws_secret_key": "{{env `AWS_SECRET_KEY`}}",
    "aws_region": "{{ env `AWS_REGION` }}"
  }
}
```

```bash

```

## Template Debugging

```bash
PACKER_LOG=1 packer build -debug ubuntu.json |& tee debug.txt
```