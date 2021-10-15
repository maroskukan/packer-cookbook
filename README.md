# Packer Cookbook

- [Packer Cookbook](#packer-cookbook)
  - [Introduction](#introduction)
  - [Documentation](#documentation)
  - [Installation](#installation)
  - [Architecture](#architecture)
  - [Template Inspection](#template-inspection)
  - [Template Validation](#template-validation)

## Introduction

Packer automates the creation of customized images in a repeatable manner.

## Documentation

[Packer Landing Page](https://www.packer.io/)

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

Packer divides the image build process in these main components:

- Builder
- Provisioner
- Post-processor

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