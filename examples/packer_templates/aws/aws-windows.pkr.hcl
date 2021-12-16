locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

data "amazon-ami" "windows_2012r2" {
  filters = {
    name = "Windows_Server-2012-R2_RTM-English-64Bit-Base*"
  }
  most_recent = true
  owners      = ["801119661308"] # Canonical
  region      = "us-east-1"
}

data "amazon-ami" "windows_2019" {
  filters = {
    name = "Windows_Server-2019-English-Full-Base-*"
  }
  most_recent = true
  owners      = ["801119661308"]
  region      = "us-east-1"
}


source "amazon-ebs" "windows-2012r2" {
  ami_name       = "my-windows-2012-aws-{{timestamp}}"
  communicator   = "winrm"
  instance_type  = "t2.micro"
  region         = "us-east-1"
  source_ami     = "${data.amazon-ami.windows_2012r2.id}"
  user_data_file = "./scripts/SetUpWinRM.ps1"
  winrm_insecure = true
  winrm_use_ssl  = true
  winrm_username = "Administrator"
  tags = {
    "Name"        = "MyWindowsImage"
    "Environment" = "Production"
    "OS_Version"  = "Windows"
    "Release"     = "Latest"
    "Created_By"  = "Packer"
  }
}

source "amazon-ebs" "windows-2019" {
  ami_name       = "my-windows-2019-aws-{{timestamp}}"
  communicator   = "winrm"
  instance_type  = "t2.micro"
  region         = "us-east-1"
  source_ami     = "${data.amazon-ami.windows_2019.id}"
  user_data_file = "./scripts/SetUpWinRM.ps1"
  winrm_insecure = true
  winrm_use_ssl  = true
  winrm_username = "Administrator"
}

build {
  sources = [
    "source.amazon-ebs.windows-2012r2",
    "source.amazon-ebs.windows-2019",
  ]

  post-processor "manifest" {
  }
}