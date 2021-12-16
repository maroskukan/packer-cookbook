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
  - [Packer CLI](#packer-cli)
    - [build](#build)
    - [fix](#fix)
    - [fmt](#fmt)
    - [inspect](#inspect)
    - [validate](#validate)
    - [hcl2_upgrade](#hcl2_upgrade)
  - [Environment Variables](#environment-variables)
  - [Workflow](#workflow)
    - [AWS Example](#aws-example)
  - [Templates](#templates)
    - [HCL Formatting](#hcl-formatting)
    - [Block Organization](#block-organization)
    - [Comments](#comments)
    - [Interpolation syntax](#interpolation-syntax)
    - [Plugin architecture](#plugin-architecture)
  - [Builders](#builders-1)

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

```hcl
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

```hcl
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

```hcl
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

You can optionally enable autocompletion for Packer CLI

```bash
packer -autocomplete-install
```

## Packer CLI

Subcommands available in Packer:
```bash
Usage: packer [--version] [--help] <command> [<args>]

Available commands are:
    build           build image(s) from template
    console         creates a console for testing variable interpolation
    fix             fixes templates from old versions of packer
    fmt             Rewrites HCL2 config files to canonical format
    hcl2_upgrade    transform a JSON template into an HCL2 configuration
    init            Install missing plugins or upgrade plugins
    inspect         see components of a template
    validate        check that a template is valid
    version         Prints the Packer version
```

Most of the commands accept or require flags or arguments to execute the desired functionality.

### build

Takes a Packer template and runs all the defined builds to generate the desired artifacts. The build command provides the core functionality of Packer.

```bash
packer build base-image.pkr.hcl
```

Important arguments:
- -debug - enables debug mode for step-by-step troubleshooting
- -var - sets a variable in the Packer template
- -var-file - use a separate variable file

### fix

Takes a tempalte and finds backwards incompatible parts of it and brings it up to date so it can be used with the latest version of Packer. Use after you update Packer to a new release version.

### fmt

Used to format your Packer templates and files to the preferred HCL canonical format and style.

### inspect

Shows all components of a Packer template including variables, builds, sources, provisioners and post-procesors.

### validate

Validates the syntax and the configration of your packer template. This is your first validation for templates after writing or updating them.

### hcl2_upgrade

Translates a template written in the older JSON format to the new HCL2 format.


## Environment Variables

Packer has a few environment variables that you should know:
- PKACER_LOG - enable Packer detauled logs (off by default)
- PACKER_LOG_PATH - set the path for Packer logs to specified file (rather than stderr)
- PKR_VAR_<name> - define a variable value using ENV rather than in a template

```bash
# Enable Detailed Logs
export PACKER_LOG=1

# Set a path for logs
export PACKER_LOG_PATH=/var/log/packer.log

# run the packer build
packer build base-image.pkr.hcl
```

```bash
# Declare a value for the aws_region variable using ENV
export PKR_VAR_aws_region=us-east-1
packer build aws-base-image.pkr.hcl
```


## Workflow

### AWS Example

1. HCL2 Template
2. Packer Build
3. Provision Instance
4. Run Provisioners (pull artifacts if required)
5. Create AMI
6. Register AMI
7. Destroy Instance

## Templates

The core functionality and behavior of Packer is defined by a template.
Templates consist of declarations and command, such as what plugins (builders, provisioners, etc.) to use, how to configure the plugins. and what order to run them.

Packer currently supports two format for templates:
- JSON (Javascript Object Notation)
- HCL2 (HashiCorp Configuration Language)

### HCL Formatting

- Configuration format is VCS friendly (multi-line lists, training commands, auto-formatting)
- Only code blocks built into the HCL language are available to use
- Packer uses a standard file name for simplicity <name>.pkr.hcl
- Uses Syntax Constructs like Blocks and Arguments
- New features will only be implemented for the HCL format moving forward

### Block Organization

- In general, the ordering of root blocks is not significat within a Packer template since Packer uses a declarative model. References to other resources do not depend on the order they are defined.
- Blocks can even span multiple Packer template files.
- The order of provisioner or post-processor blocks within a build is the only major feature where block order matters.

### Comments

HCL2 supports comment to use throughout the configuration file:

```hcl
# this is a comment
source "amazon-ebs" "example" {
  ami_name = "abc123"
}
// this is also a comment

/* <-this is a multi-line comment
source "amazon-ebs" "example {
  amin_name = "abc123"
}
*/
variable "example" {
```

### Interpolation syntax

- Like Terraform, we can use interpolation syntax to refer to other blocks within the template
- Allows us to orgamize code as well as reuse values that are already defined or have been retrieved

### Plugin architecture

- Builders, provisioners, post-processors, and data sources are simply plugins that are consumed during the Packer build process
- This allows new functionality to be added to Packer without modifying the core source code


## Builders

- Builders are responsible for creating machines and generating images from them for various platforms
- You can specify one or more builder blocks in a template.
- Each builder block can reference one or more source blocks.
- There are many configuration options for a given builder. Some options are required, and others are optional. The optional are dependent on the what the builder type supports.

Popular buidlers include:
- AWS AMI Builder
- Azure Resource Manager Builder
- VMware Builder from ISO
- VMware vSphere Clone Builder
- VMware vSphere Builder from ISO
- Docker Builder
- Google Compute Builder
- Null Builder
- QEMU Builder
- Virtual Box Builder

