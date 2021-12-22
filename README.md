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
    - [Limits and Exceptions](#limits-and-exceptions)
  - [Variables](#variables-1)
    - [Introduction](#introduction-1)
    - [Use Cases](#use-cases-1)
    - [Declaration](#declaration)
    - [Types](#types)
    - [Usage](#usage)
    - [Precedence](#precedence)
    - [Locals](#locals)
    - [Environment](#environment)
  - [Provisioners](#provisioners-1)
    - [File](#file)
    - [Shell](#shell)
    - [Ansible](#ansible)
    - [PowerShell](#powershell)
    - [Features](#features)
  - [Post-Processors](#post-processors-1)
    - [Manifest](#manifest)
    - [Shell-local](#shell-local)
    - [Compress](#compress)
    - [Checksum](#checksum)
  - [Code Organization](#code-organization)
    - [Organizational Patters](#organizational-patters)
    - [Build Options](#build-options)
    - [Syntax Highlighting](#syntax-highlighting)
  - [Troubleshooting](#troubleshooting)
    - [Debug](#debug)
    - [on-error](#on-error)
    - [Breakpoint provisioner](#breakpoint-provisioner)
  - [Integrations](#integrations)
    - [Ansible](#ansible-1)
    - [Terraform](#terraform)

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

### Limits and Exceptions

When using multi-image or multi-cloud packer templates, it may be useful to limit the scope of the build by using `only` and `except` options.

```bash
# Display packer build options
packer build --help | grep 'only\|except'
  -except=foo,bar,baz           Run all builds and post-processors other than these.
  -only=foo,bar,baz             Build only the specified builds.

# Build image only for AWS
packer build -only="*amazon*" agnostic/ubuntu.pkr.hcl
```


## Variables

### Introduction

- Packer can use variables to define defaults and values during a build
- Work a lot like variables from other programming languages
- Allow you to remove hard coded vallues and pass parameters to your configuration
- Can help make configuration easier to understand and increase reusability
- Must always have a value. Variables are optional, and they can have a default value

### Use Cases

- Use variables to pass value to your configuration
- Refector existing configuraiton to use variables
- Keep sensitive data out of source control
- Pass variable to Packer in several ways

### Declaration

- Variables can be declared and defined in a `.pkrvars.hcl` file or `.auto.pkrvars.hcl` the default .pkr file, or any other file name if referenced when executing the build.
- You can also declare individually using the `-var` option.
- Declare variables can be accessed through the template where needed within expressions.
- The type is a constant, meaning that's the only value that will be accepted for that variable.

### Types

- The most common variable types are string, number, list and map.
- Other support types include bool (true/false), set, objects, and tuple
- If type is omitted, it is inferred from the default value
- If neither type nor default is provided, the type is assumed to be string
- You can also specify complex types, such as collections

```hcl
variable "image_id" {
  type        = string
  description = "The id of machine image (AMI)."
  default     = "ami-1234abcd"
}
```

```hcl
variable "image_id" {
  type        = list(string)
  description = "The id of the machine image (AMI)."
  default     = ["ami-1234abcd", "ami-1z2y3x445v"]
}
```

A variable can be marked as senstive if required telling packer to obfuscate it from the output.

```hcl
variable "ssh_password" {
  sensitive = true
  default   = {
    key = "SuperSecret123"
  }
}
```

```bash
$ packer inspect password.pkr.hcl
Packer Inspect: HCL2 mode

> input-variables:
var.ssh_password: "{\n \"key\" = \"<sensitive>\"\n }"
```

### Usage

There are two main how we can refer to a variable.

- General Referral in Packer `var.<name>`
- Interpolation within a String `"${var.<name>}"`

Example of general referral in template:

```hcp
image_name = var.image_name
subnet_id = var.subnet
vpc_id = var.vpc
```

Example of interpolation within a string:
```hcp
image_name = "${var.prefix}-iamge-{{timestamp}}"
```

- Declared  variables can be accessed throughout the template where needed
- Reference variables using expressions such as `var.<name>` or `"${var.<name>}"`

```hcp
source "amazon-ebs" "aws-example" {
  ami_name      = "aws-${var.ami_name}"
  instance_type = "t3.medium"
  region        = "var.region
  source_ami_filter {
    filters = {
      name                = var.source_ami_name
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners = [var.source_ami_owner]
  }
}
```

To change the default variable value we can use `=` operator, for example:

```hcp
variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI)"
  default     = "ami-1234abcd"
}
```

Define variable in another file e.g. `variables.pkrvars.hcl`
```hcp
image_id = "ami-5678wxyz"
```

Or define variable with command line argument:
```bash
packer build -var image_id=ami=5467wxyz aws-build.pkr.hcl
```

### Precedence

Lowest to highest priority:

1. Default Values
2. Environment Variables
3. Variable Definition File
4. Using the `-var` or `-var-file` CLI option
5. Variables Entered via CLI Prompt

### Locals

- Similar to input variables, assign a name to an expression or value
- Locals cannot be overridden at runtime - they are constants
  - Can use a `local {}` or `locals {}` block - can mark local as senstive
  - Using `locals {}` is more compact and efficient
- Referenced in a Packer file through interpolation - local.<name>

```hcp
locals {
  timestamp = regex_repace(timestamp(), "[- TZ:]", "")
}

variable "image_name" {
  image_name = "${var.ami_prefix}-${local.timestamp}"
}
```
### Environment

- Variables can also be set using environment variables
- Great solution for setting credentials or variables that might change often
- Packer will read environment variables in the form of `PKR_VAR_<name>`

```bash
# set environment variables
export PKR_VAR_secret_key=AIOAJSFJAIFHEXAMPLE
export PKR_VAR_access_key=wPWOIAOFIJwohfalskfhiAUHFhnalkfjhuwahfi

# run packer build that will use ENV
packer build aws-linux.pkr.hcl
```

Packer will automatically define certain commonly used environment variables at build time that can be referenced

PACKER_BUILD_NAME - set to the name of the build that Packer is running
PACKER_BUILD_TYPE - set the type of build that was used to create the machine
PACKER_HTTP_ADDR - set to the address of the http server for file transfer (if used)


## Provisioners

- Provisioners user built-in and third-party integrations to install packages and configure the machine image
- Built-in integrations include `file` and different `shell` options.
- Third-party integrations include Ansible, Chef, InSpec, PowerShell, Puppet, Salt, Windows Shell and many [more](https://www.packer.io/docs/provisioners).

Provisioners prepare the system for use, therefore common use cases are:
- installing packages
- patching the kernel
- creating users
- downloading application code

### File

File provisioner is used to upload file(s) to image being built.

```hcl
provisioner "file" {
  source        = "packer.zip"
  desctionation = "/tmp/packer.zip"
}
```

```hcl
provisioner "file" {
  source      = "/files"
  destination = "/tmp"
}
```

### Shell

Shell provisioner can execute script or individual commands within image being built.

```hcl
provisioner "shell" {
  script = "install_something.sh"
}
```

```hcl
provisioner "shell" {
  inline = [
    "echo Updating package list and installing software",
    "sudo apt-get update",
    "sudo apt-get install -y nginx"
  ]
}
```

### Ansible

Ansible provisioner runs playbooks. It dynamically creates an inventory file configured to use SSH.

```hcl
provisioner "ansible" {
  ansible_env_vars  = ["ANSIBLE_HOST_KEY_CHECKING=False"]
  extra_arguments   = ["--extra-vars", "desktop=false"]
  playbook_file     = "${path.root}/playbooks/playbook.yml"
  user              = var.ssh_username
}
```

### PowerShell

```hcl
provisioner "powershell" {
  script = [".scripts/win2019.ps1"]
}
```

### Features

Provisioners supports `only` and `except` options to run only on specific builds. The `override` options can be useful when building images across different platforms so you end up with a like-for-like images.

```hcl
provisioner "shell" {
  inline = ["./tmp/install_vmware-tools.sh"]
  override = {
    aws = {
      inline = ["./tmp/install_cloudwatch_agent.sh"]
    }
  }
}
```

The `error-cleanup-provisioner` can invoke a provisioner that only runs if related provsioner fails. It runs before the instane is shutdown or terminated. For example write data to a file, unsubscribe from a service or clean up custom work.

```hcl
build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    inline = ["sudo yum update -y"]
  }
  error-cleanup-provisioner "shell-local" {
    inline = ["echo 'update provisioner failed'> packer_log.txt"]
  }
}
```

The `pause_before` option can provide a waiting period. This is useful when it takes a bit for the OS to compe up, or other processes are running that could conflict with provisioner.

```hcl
build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    inline = ["sudo apt-get update -y"]
    pause_before = "10s"
  }
}
```

The `max_retries` option can restart provisioner if it failed. It is helpful when provisioner depends on external data/processes to complete successfully.

```hcl
build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    inline = ["sudo yum update -y"]
    max_retries = 5
  }
}
```

The `timeout` option can be used to define maximum time that the provisioner should complete its task, before it is considered as failed.

```hcl
build = {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    inline = ["./install_something.sh"]
    timeout = "5m"
  }
}
```


## Post-Processors

- Post-processors are executed after provisioners are complete and the image is built. It can be used to upload artifacts, execute scripts, or import an image.
- Post-processors are completely optional
- Examples include:
  - Execute a local script after the build is completed (shell-local)
  - Create a machine-readable report of what was build (manifest)
  - Incorporate within a CI/CD build pipeline to be used for additional steps
  - Compute a checksum for the artifact so you verify it later (checksum)
  - Import a packege to AWS after building in your data center (AWS)
  - Convert the artifact into a Vagratn box (Vagrant)
  - Create a VMware template from the resulting build (vSphere Template)

### Manifest

Defined in build block, each post-processor runs after each defined build. The post-processor takes the artifact from a build, uses it, and deletes the artifact after it is done (default behavior)

Post-processor defines a sinle post-processor.

The manifest creates a JSON file with a list of all the artifacts that packer created during build. The file is invoked each time a build completes and the file is updated.

Default file name is `packer-manifest.json` but can be updated using the `output` option.

```hcl
build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "echo Updating Packages and Installing nginx",
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx"
    ]
  }

  post-processor "manifest" {
    output = "my-first-manifest.json"
  }
}
```

### Shell-local

The local shell post processor enables you to execute scripts locally after the machine image is built. It is helpful for chaining tasks to your Packer build after it is completed. You can pass in environment variables, customize how the command is executed, and specify the script to be executed.

```hcl
build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y"
    ]
  }

  post-processor "shell-local" {
    environment_vars = ["ENVIRONMENT=production"]
    scripts = ["./scripts/update_docs.sh"]
  }
}
```

### Compress

- Takes the final artifact and compresses it into a single archive
- By default, this post-processor compresses files into as ingle tarball (.tar.gz file)
- However, the following extensions are supported: .zip, .gz, .tar.gz, .lz4 and .tar.lz4
- Very helpful if you're build packages locally - vSphere, Vagrant. etc

```hcl
build {
  sources = [
    "source.amazon-ebs.amazonlinux-2"
  ]

  post-processor "compress" {
    output = "{{.BuildName}}-image.zip
  }
}
```

### Checksum

- Computes the checksum for the current artifact
- Useful to validate no changes occured to the artifact since running the packer build
- Cane be used during validation phase of a CI/CD pipelien

```hcl
build {
  sources = [
    "source.amazon-ebs.amazonlinux-2"
  ]

  post-processor "checksum" {
    checksuym_types = ["sha1", "sha256"]
    output          = "packer_{{.BuildName}}_{{.ChecksumType}}.cheksum"
  }
}
```


## Code Organization

- Packer configuration can be a single file or split across multiple files. Packer will process all files in the current working directory which end in .pkr.hcl and .pkvars.hcl.
- Sub-folders are not included (non-recursive)
- Files are processed in lexicographical (dictionary) order
- Any files with a different extensions are ignored
- Generally, the order in which things are defined doesn't matter
- Parsed configurations are appended to each other, not merged
- Sources with the same name are not merged (this will produce and error)
- Configuration syntax is declarative, so references to other resources do not depend on the order they are defined

### Organizational Patters

Pattern A:

```bash
$ ls
main.pkr.hcl
variables.pkvars.hcl
```

Pattern B:

```bash
$ ls
aws.pkr.hcl
azure.pkr.hcl
gcp.pkr.hcl
vmware.pkr.hcl
variables.pkvars.hcl
```

Pattern C:

```bash
$ ls
ubuntu.pkr.hcl
windows.pkr.hcl
rhel.pkr.hcl
variables.pkvars.hcl
```

Pattern D:

```bash
everything.pkr.hcl
```

### Build Options

```bash
# Validate and Build all Items
# in a working directory
$ packer validate .
$ packer build .

# Specify certain cloud target
$ packer build -only "*.amazon.*"

# Specify certain OS types
$ packer build -only "*.ubuntu.*"

# Specify individual template
$ packer build aws.pkr.hcl
```

### Syntax Highlighting

Plugins for Packer/HCL exists for most major editors, but Terraform tends to work best of one does not exist for Packer.


## Troubleshooting

### Debug

In order to display live debug debug information, you can set the `PACKER_LOG` environment variable.

```bash
export PACKER_LOG=1
```

```powershell
$env:PACKER_LOG=1
```

In order to save debug information. you can set the `PACKER_LOG_PATH` environment variable to desired file.

```bash
export PACKER_LOG_PATH="packer_log.txt"
```

```powershell
$env:PACKER_LOG_PATH="packer_log.txt"
```

To disable logging change the variable values to defaults.

```bash
export PACKER_LOG=0
export PACKER_LOG_PATH=""
```

```powershell
$env:PACKER_LOG=0
$env:PACKER_LOG_PATH=""
```

You can also leverage packer build with the `-debug` option to step through the build process. This however disabled parallel build process. This is useful for remote buidls in cloud environment.

### on-error

Packer also provides the ability to inspect failures durin the debug process. The `on-error=ask` option allows you to inspect failures and try out solutiosn before restarting the build.

```bash
packer build --help | grep 'on-error'
  -on-error=[cleanup|abort|ask|run-cleanup-provisioner] If the build fails do: clean up (default), abort, ask, or run-cleanup-provisioner.
```

### Breakpoint provisioner

This provisioner will pause until user presses enter to resume the build. This is useful for debugging.

```bash
packer build packer-breakpoints.pkr.hcl
null.debug: output will be in this color.

==> null.debug: Running local shell script: /tmp/packer-shell2159196625
    null.debug: hi
==> null.debug: Pausing at breakpoint provisioner with note "this is a breakpoint".
==> null.debug: Press enter to continue.
==> null.debug: Running local shell script: /tmp/packer-shell389208221
    null.debug: hi 2
Build 'null.debug' finished after 1 second 317 milliseconds.

==> Wait completed after 1 second 317 milliseconds

==> Builds finished. The artifacts of successful builds are:
--> null.debug: Did not export anything. This is the null builder
```


## Integrations

### Ansible

Packer provides two types of provisioners that work with Ansible. Ansible Remote that assumes that Ansible is available on the provisioning host and Ansible Local that assumes that Ansible is available in the template being build. In either cases the goal is to provision software and configuration through Ansible playbooks.

The benefit of using playbooks during image building is that they can be reused again during instance provisioning.

### Terraform

Terraform is a tool that uses declarative configuration files written in HashiCorp Configuration Language (HCL) similar to Packer. It is great tool for deploying instances from images that were created by Packer.

```bash

# Prepare your working directory (verify config, install plugins)
terraform init

# Show changes required for current configuration
# This will ask for AMI ID which can be retrieved
# from Packer manifest file. (e.g. ami-013b85e4903b8d807)
terraform plan

# Create or update infrastructure
terraform apply

# Destroy previously-created infrastructure
terraform destroy
```

You can also reference an existing image using data block inside terraform template.

```hcl
data "aws_ami" "packer_image" {
  most_recent = true

  filter {
    name = "tag:Created-by"
    values = ["Packer"]
  }

  filter {
    name = "tag:Name"
    values = [var.appname]
  }

  owners = ["self"]
}
```

And then validate and plan the new deployment.

```bash
$ terraform validate
Success! The configuration is valid.

# Perform a dry run
$ terraform plan -var 'appname=ClumsyBird'

# Execute the deployment
$ terraform apply -var 'appname=ClumsyBird'
```