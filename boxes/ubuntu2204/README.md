# Ubuntu 22.04 LTS (Jammy Jellyfish) Vagrant Box

Current Ubuntu Version Used: 22.04

```json
{
    "version": "22.04",
    "installer": "subiquity",
}
```


## Usage

### Powershell

```powershell
# Setup Access token
$ENV:VAGRANT_CLOUD_TOKEN = "your-vagrant-cloud-access-token"

# Setup Box version
$ENV:BOX_VERSION = "0.0.1"

# Validate
packer validate .\box-config.pkr.hcl

# Build and push
packer build .\box-config.pkr.hcl
```

### Bash

```bash
# Setup Access token
export VAGRANT_CLOUD_TOKEN = "your-vagrant-cloud-access-token"

# Setup Box version
export BOX_VERSION = "0.0.1"

# Validate
packer validate ./box-config.pkr.hcl

# Build and push
packer build ./box-config.pkr.hcl
```