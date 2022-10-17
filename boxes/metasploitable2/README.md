# Metasploitable2 Vagrant Box

- [Metasploitable2 Vagrant Box](#metasploitable2-vagrant-box)
  - [Introduction](#introduction)
  - [Disk Conversion](#disk-conversion)
  - [Create VM](#create-vm)
  - [Customize OS](#customize-os)
    - [Users](#users)
    - [Filesystem](#filesystem)
  - [Box Packaging](#box-packaging)
    - [Vagrant Box Directory](#vagrant-box-directory)
    - [VM Export](#vm-export)
    - [Box exporting](#box-exporting)
  - [Box testing](#box-testing)
  - [Vagrant Cloud](#vagrant-cloud)

## Introduction
This build is unique as it starts with a predefined Virtual Box Virtual Machine [files](https://docs.rapid7.com/metasploit/metasploitable-2/) based on top of `Ubuntu 8.04` running `Kernel 2.6.24-16-server` provided by Rapid7 with respect to [HD Moore](https://twitter.com/hdmoore).

In order to produce a fully functional Vagrant Box for Hyper-V environment follow these steps from a Windows based environment.


## Disk Conversion

Extract the downloaded archive and convert the existing disk image file format from `vmdk` to `vhdx` using the [qemu-img](https://community.chocolatey.org/packages/qemu-img) application.

```powershell
qemu-img convert .\Metasploitable.vmdk -O vhdx -o subformat=dynamic .\Metasploitable.vhdx
```

## Create VM

Using Hyper-V Manager, create a new Generation 1 virtual machine with default `1024` MB Startup memory with Dynamic Memory, leave network as default and use existing disk `Metasploitable.vhdx` which you converted in previous step.

Once the VM is created, update its settings by removing the existing network adapter and adding a new Hardware - `Legacy Network Adapter`. Make sure its connected to `Default Switch`.

Finally power on the VM.


## Customize OS

In order to make this image play nicely with Vagrant, there are some additional customizations that needs to take place.

Start by accessing the VM console and logging in as `msfadmin` with password `msfadmin`. Retrieve the currently assigned IP address in order to connect through SSH.

> **Note**: In order to escape the virtual console use the `CTRL+ALT+Left Arrow`

```bash
ip address show dev eth0 | grep global | awk '{ print $2 }' | cut -d"/" -f1
```

The output of this filtering magic should be similar to output below.

```bash
172.17.128.140
```

Close the console session with `exit` and connect through SSH using the same username. This will allow you to use console copy-and-paste buffer. Once you have access through SSH gain root shell with `sudo -i`.

### Users

```bash
# Create Vagrant User and add it to admin group
useradd -m -G admin vagrant

# Set default password
echo 'vagrant:vagrant' | sudo chpasswd

# Create .ssh directory and add trusted key
mkdir -p /home/vagrant/.ssh
cat << EOF > /home/vagrant/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF

# Update the ownership and permissions
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# Remove .bashrc - causes issues with command autocompletion
rm -rf /home/vagrant/.bashrc

# Cleanup history
export HISTSIZE=0
```


### Filesystem

In order to conserve space we will wipe you any free available space on `/` and `/boot` with zeros.

```bash
# Whiteout root
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
count=$(($count-1))
dd if=/dev/zero of=/tmp/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
rm /tmp/whitespace

# Whiteout /boot
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
count=$(($count-1))
dd if=/dev/zero of=/boot/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
rm /boot/whitespace
```

Finally `sync` the filesystem and `poweroff` the machine`.

```bash
sync
poweroff
```


## Box Packaging

### Vagrant Box Directory

Start by create a destination folder structure that Vagrant recognizes. If you want to upload this box to Vagrant cloud it make sense to include your username and box name as follows:

```powershell
$VagrantCloudUser = 'maroskukan'
$VagrantBoxName = 'metasploitable2'
$VagrantBoxVersion = '2022.10.17'
$VagrantBoxProvider = 'hyperv'
```

Create required folders.

```powershell
# Create container folder
New-Item -ItemType Directory `
         -Path $HOME/.vagrant.d/boxes/$VagrantCloudUser-VAGRANTSLASH-$VagrantBoxName

# Create version folder and metadata
New-Item -ItemType Directory `
         -Path $HOME/.vagrant.d/boxes/$VagrantCloudUser-VAGRANTSLASH-$VagrantBoxName/$VagrantBoxVersion/$VagrantBoxProvider/'Virtual Hard Disks'

New-Item -ItemType Directory `
         -Path $HOME/.vagrant.d/boxes/$VagrantCloudUser-VAGRANTSLASH-$VagrantBoxName/$VagrantBoxVersion/$VagrantBoxProvider/'Virtual Machines'
```

Create required metadata.

```powershell
# Create metadata
"https://vagrantcloud.com/$VagrantCloudUser/$VagrantBoxName" `
| Add-Content $HOME/.vagrant.d/boxes/$VagrantCloudUser-VAGRANTSLASH-$VagrantBoxName/metadata_url

'{"provider":"hyperv"}' `
| Add-Content $HOME/.vagrant.d/boxes/$VagrantCloudUser-VAGRANTSLASH-$VagrantBoxName/$VagrantBoxVersion/$VagrantBoxProvider/metadata.json
```

Optionally, you can add more information to specific version and provider. Place these files in provider folder.

`$HOME/.vagrant.d/boxes/$VagrantCloudUser-VAGRANTSLASH-$VagrantBoxName/$VagrantBoxVersion/$VagrantBoxProvider/info.json`
```json
{
 "Author": "Maros Kukan",
 "Website": "https://buldogchef.com",
 "Artifacts": "https://vagrantcloud.com/maroskukan/",
 "Repository": "https://github.com/maroskukan/packer-cookbook",
 "Description": "Packaged metasploitable2 VM for Hyper-V."
}
```

`$HOME/.vagrant.d/boxes/$VagrantCloudUser-VAGRANTSLASH-$VagrantBoxName/$VagrantBoxVersion/$VagrantBoxProvider/Vagrantfile`
```ruby
# The contents below were provided by the Packer Vagrant post-processor


# The contents below (if any) are custom contents provided by the
# Packer template during image build.
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.synced_folder ".", "/vagrant", type: "rsync"
  config.vm.network "public_network", bridge: "Default Switch"

  # Hyper-V Provider Specific Overrides
  config.vm.provider "hyperv" do |h, override|
    h.enable_virtualization_extensions = true
    h.linked_clone = true
    h.cpus = 2
    h.memory = 2048
    h.maxmemory = 2048
  end
end
```

### VM Export

In order to repackage a Virtual Machine files later on, you need to ensure there are no associated checkpoints. In this example the VM name is set to `meta`.

```powershell
$VMName = 'meta'
```

```powershell
Get-VMSnapshot -vmname $VMName | Remove-VMSnapshot
```

Next, retrieve the Virtual Machine ID. You will need this to identify the required configuration files that Hyper-V creates.

```powershell
$VMid = $(Get-VM $VMName | Select -ExpandProperty VMid).Guid
```

Next, copy existing VM files.

```powershell
Get-ChildItem -path "$Env:ProgramData\Microsoft\Windows\Hyper-V\Virtual Machines" ${VMid}* | where { !$_.PSisContainer } | copy-item -destination $HOME/.vagrant.d/boxes/$VagrantCloudUser-VAGRANTSLASH-$VagrantBoxName/$VagrantBoxVersion/$VagrantBoxProvider/'Virtual Machines'
```

Next, copy the disk file you created in disk conversion [step](#disk-conversion).

```powershell
copy-item Metasploitable.vhdx $HOME/.vagrant.d/boxes/$VagrantCloudUser-VAGRANTSLASH-$VagrantBoxName/$VagrantBoxVersion/$VagrantBoxProvider/'Virtual Hard Disks'
```

We now have all we need from the source VM. You can safely delete it.

```powershell
Remove-VM $VMName -Force
```


### Box exporting

If everything worked out in previous steps, you should now see a new box in the list

```powershell
vagrant box list | findstr $VagrantCloudUser/$VagrantBoxName
```

You should see output similar to below:

```powershell
maroskukan/metasploitable2    (hyperv, 2022.10.17)
```

To create a `.box` file which you can upload to Vagrant cloud use the `repackage` argument.

```powershell
vagrant box repackage $VagrantCloudUser/$VagrantBoxName $VagrantBoxProvider $VagrantBoxVersion
```

This will create a `package.box` file in the current working directory. Once we are done with functional testing we will upload this file to Vagrant Cloud.


## Box testing

Lets start with importing the box file into Vagrant.

```powershell
vagrant box add $VagrantCloudUser/$VagrantBoxName-test file:///$pwd/package.box
```

Then create simple Vagrantfile.

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Hyper-V Provider Specific Configuration
  config.vm.provider "hyperv" do |h|
    h.enable_virtualization_extensions = true
    h.linked_clone = true
    h.memory = 2048
    h.maxmemory = 2048
  end

  config.vm.define "meta" do |meta|
    # VM Shared Configuration
    meta.vm.box = "maroskukan/metasploitable2-test"
    meta.vm.hostname = "metasploitable2"
    # Hyper-V VM Specific Configuration
    meta.vm.provider 'hyperv' do |h, override|
      override.vm.synced_folder ".", "/vagrant", type: "rsync"
      override.vm.network "public_network", bridge: "Default Switch"
    end
  end
  config.ssh.insert_key = false
end
```

Finally, provision the VM with `vagrant up`.

```powershell
vagrant up
```

You should see output similar to below:

```powershell
Bringing machine 'meta' up with 'hyperv' provider...
==> meta: Verifying Hyper-V is enabled...
==> meta: Verifying Hyper-V is accessible...
==> meta: Importing a Hyper-V instance
    meta: Creating and registering the VM...
    meta: Successfully imported VM
    meta: Configuring the VM...
    meta: Setting VM Enhanced session transport type to disabled/default (VMBus)
==> meta: Starting the machine...
==> meta: Waiting for the machine to report its IP address...
    meta: Timeout: 120 seconds
    meta: IP: 172.17.139.78
==> meta: Waiting for machine to boot. This may take a few minutes...
    meta: SSH address: 172.17.139.78:22
    meta: SSH username: vagrant
    meta: SSH auth method: private key
==> meta: Machine booted and ready!
==> meta: Setting hostname...
The following SSH command responded with a non-zero exit status.
Vagrant assumes that this means the command failed!

          grep -w 'metasploitable2' /etc/hosts || {
            for i in 1 2 3 4 5; do
grep -w "127.0.${i}.1" /etc/hosts || {
  echo "127.0.${i}.1 metasploitable2 metasploitable2" >> /etc/hosts
  break
}
            done
          }


Stdout from the command:



Stderr from the command:
```

> **Note**: It is expected that the VM customizations performed by Vagrant fail. The reason is that Vagrant uses tools that are dependent systemd and the source VM runs on old version of Ubuntu that does not have it installed. Nevertheless this should not affect the usability.

Finally, verify that you are able to log in to the VM and gain root privileges.

```powershell
vagrant ssh
Linux metasploitable 2.6.24-16-server #1 SMP Thu Apr 10 13:58:00 UTC 2008 i686

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To access official Ubuntu documentation, please visit:
http://help.ubuntu.com/
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.
```

```bash
echo 'vagrant' | sudo -S id
[sudo] password for vagrant:
uid=0(root) gid=0(root) groups=0(root)
```

This concludes the testing phase, feel free to shutdown the VM and cleanup the environment.

```powershell
vagrant destroy -f
vagrant box remove $VagrantCloudUser/$VagrantBoxName-test
```


## Vagrant Cloud

To make this box available for other Vagrant users, we need to upload the `package.box` file to Vagrant cloud with its hash for file integrity.

```powershell
$BoxFH = Get-FileHash .\package.box
$BoxFH.Hash
```

Creating a new box and version using Web UI is straightforward. Once the file upload is completed, the box is ready to use. You can use the included `Vagrantfile` as an example.
