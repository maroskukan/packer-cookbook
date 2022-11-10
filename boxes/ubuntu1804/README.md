# Ubuntu 18.04 LTS (Bionic Beaver) Vagrant Box


```yml
version: 18.04
installer: debian-installer
providers:
  - hyperv
  - vmware_desktop
  - virtualbox
```


## Usage

### Powershell

```powershell
# Setup Access token
$ENV:VAGRANT_CLOUD_TOKEN = "your-vagrant-cloud-access-token"

# Validate
packer validate .\box-config.pkr.hcl

# Build and push
packer build .\box-config.pkr.hcl
```

### Bash

```bash
# Setup Access token
export VAGRANT_CLOUD_TOKEN = "your-vagrant-cloud-access-token"

# Validate
packer validate ./box-config.pkr.hcl

# Build and push
packer build ./box-config.pkr.hcl
```