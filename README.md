# Packer Cookbook

- [Packer Cookbook](#packer-cookbook)
  - [Introduction](#introduction)
    - [Use Cases](#use-cases)
    - [Benefits](#benefits)
  - [Documentation](#documentation)
  - [Architecture](#architecture)
  - [Core Components](#core-components)
    - [Source](#source)
    - [Builders](#builders)
    - [Provisioners](#provisioners)
    - [Post-Processors](#post-processors)
    - [Communicators](#communicators)
    - [Variables](#variables)
  - [Installation](#installation)
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


## Architecture

Packer is written in Go language and compiled as single binary for various operating systems (Windows, Linux, macOS). It is modular and very extensible.

Packer builds images using a tempalte. Templates can be build using either `json` (old) or `hcl2` (recommended for v1.7.0+).

Templates defines settings using blocks:
- Original Image to Use (source)
- Where to Build the Image (AWS, VMware, Openstack)
- Files to Upload to the Image (scripts, packages, certificates)
- Installation and Configuration of the Machine Image
- Data to Retrieve when Building

## Core Components

- Source
- Builders
- Provisioner
- Post-Processors
- Communicators
- Variables

### Source

Source defines the initial image to use to create your customized image. Any defined source is reusable within build blocks.

For example:
- Building a new AWS image (AMI), you need to point to an existing AMI to customize
- Create a new vSphere template requires the name of the source VM
- Building a new Google Compute images needs a source image to start

```ruby
source "azure-arm" "azure-arm-centos-7" {
  image_offer     = "CentOS"
  image_publisher = "OpenLogic"
  image_sku       = "7.7"
  os_type         = "Linux"
  subscription_id = "${var.azure_subscription_id}"
}

```

### Builders

- Builders are responsible for creating machines from the base images, customizing the image as defined, and then createing a resulting image
- Builders are plugins that are developed to work wit ha specific platform (AWS, Azure, VMware, OpenStack, Docker)
- Everything done to the image is done within the BUILD block
- This is where customization "work" happens

```ruby
build {
  source = ["source.azure-arm.azure-arm-centos-7"]

  provisioner "file" {
    destination = "/tmp/package_a.zip"
    source      = "${var.package_a_zip}"
  }
}
```

### Provisioners

- Provisioners use built-in and third-party integration to **install packages** and **configure the machine image**
- Built-in integrations include **file** and different **shell** options
- Third-party integrations include:
  - **Ansible** -run playbooks
  - **Chef** - run cookbooks
  - **InSpec** - run InSpec profiles
  - **PowerShell** - execute PowerShell scripts
  - **Puppet** - run Puppet manifest
  - **Salt** - configure baed on Salt state
  - **Windows Shell** - runs commands using Windows cmd

### Post-Processors

- Post-processors are executed after the image is build and provisioners are complete. They can be used to upload artifacts, execute uploaded scripts, validate installs, or import an image.
- Examples include:
  - Validate a package using a checksum
  - Import a package to AWS as an AMI
  - Push a Docker image to registry
  - Convert the artifact into a Vagrant box
  - Create a VMware tempalte from the resulting build

### Communicators

- Communicators are the mechanism that Packer will use to communicate with the new build and upload files, execute scripts, etc.
- Two Communicators available today:
  - SSH
  - WinRM

### Variables

- HashiCorp Packer can use variables to define defaults during a build
- Variables can be declared in a **.pkrvars.hcl** file or **.auto.pkrvars.hcl**, the default .pkr file, or any other file name if referenced when executing the build.
- You can also declare individually using the **var** option.

```ruby
variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for server."
  default     = "ami-1234abcd"

  validation {
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}
```


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