# Kali 22.03 Vagrat Box

Current Kali Version Used: 22.03

## Usage

```powershell
# Setup Access token
$ENV:VAGRANT_CLOUD_TOKEN = "your-vagrant-cloud-access-token"

# Validate
packer validate .\box-config.pkr.hcl

# Build and push
packer build .\box-config.pkr.hcl
```