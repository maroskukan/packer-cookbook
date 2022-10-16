# Metasploitable2 Vagrant Box

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