# Ubuntu 18.04 Vagrat Box

Current Ubuntu Version Used: 18.04.6

## Usage

```powershell
# Setup Access token
$ENV:VAGRANT_CLOUD_TOKEN = "your-vagrant-cloud-access-token"

# Build and push
packer build -var 'version=0.0.1' .\box-config.pkr.hcl
```