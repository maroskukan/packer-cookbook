# Ubuntu 22.04 LTS (Jammy Jellyfish) Vagrat Box

Current Ubuntu Version Used: 22.04

```json
{
    "version": "22.04",
    "installer": "subiquity",
}
```


## Usage

```powershell
# Setup Access token
$ENV:VAGRANT_CLOUD_TOKEN = "your-vagrant-cloud-access-token"

# Validate
packer validate .\box-config.pkr.hcl

# Build and push
packer build -var 'version=0.0.1' .\box-config.pkr.hcl
```