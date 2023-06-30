# Ubuntu 22.04 LTS (Jammy Jellyfish) Vagrant Box

## Description

```yml
version: 22.04
firmware: efi
installer: subiquity
providers:
  - hyperv
  - vmwre_desktop
  - virtualbox
```

## Usage

### Powershell

```powershell
# Setup Access token
$ENV:VAGRANT_CLOUD_TOKEN = "your-vagrant-cloud-access-token"

# Install Required Plugins
packer init .\box-config.pkr.hcl

# Validate
packer validate .\box-config.pkr.hcl

# Build and push
packer build .\box-config.pkr.hcl
```

### Bash

```bash
# Setup Access token
export VAGRANT_CLOUD_TOKEN = "your-vagrant-cloud-access-token"

# Install Required Plugins
packer init ./box-config.pkr.hcl

# Validate
packer validate ./box-config.pkr.hcl

# Build and push
packer build ./box-config.pkr.hcl
```