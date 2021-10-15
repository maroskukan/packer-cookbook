# Packer Cookbook

- [Packer Cookbook](#packer-cookbook)
  - [Introduction](#introduction)
  - [Documentation](#documentation)
  - [Installation](#installation)
  - [Architecture](#architecture)

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

