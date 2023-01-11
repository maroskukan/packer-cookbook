# Kali 22.04 Vagrant Box



```yml
version: 22.04
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
export VAGRANT_CLOUD_TOKEN="your-vagrant-cloud-access-token"

# Validate
packer validate ./box-config.pkr.hcl

# Build and push
packer build ./box-config.pkr.hcl
```


## Tips

### Framebuffer mode

When using Hyper-V Generation 1 VM with GUI (`kali-desktop-xfce`) it may happen that the [X server fails to start](https://bbs.archlinux.org/viewtopic.php?id=271255), therefore login manager (gdm3,sddm,lightdm) fails as well and you are presented with black screen with blinking coursor.

After installing start the display manager.

```bash
sudo systemctl start lightdm
```

As you can TTY1 displays blinking cursor instead of login manager. To investigate further, check the `lightdm` service status.

```bash
sudo systemctl status lightdm
```

The particular log entry `lightdm.service: Triggering OnFailure= dependencies.` is interesting but does not say much where the root cause is.

Next, lets check the X server logs.

```bash
tail /var/log/Xorg.0.log
```

The output is something like this:

```bash
Fatal server error:
[   525.424] (EE) Cannot run in framebuffer mode. Please specify busIDs        for all framebuffer devices
[   525.424] (EE)
[   525.424] (EE)
Please consult the The X.Org Foundation support
         at http://wiki.x.org
 for help.
[   525.424] (EE) Please also check the log file at "/var/log/Xorg.0.log" for additional information.
[   525.424] (EE)
[   525.426] (EE) Server terminated with error (1). Closing log file.
```

To solve this we need to define the framebuffer device manually.

```bash
cat <<EOF >/etc/X11/xorg.conf.d/99-fbdev.conf
Section "Device"
        Identifier   "Card0"
        Driver       "fbdev"
        BusID        "PCI:0:8:0"
EndSection
EOF
```

Finally, restart the `lightdm` service. You should be presented with a login screen. To go beyond the default `1024x768` resolution when using Hyper-V DRM driver, you need append `video=Virtual-1:1920x1080` to `GRUB_CMDLINE_LINUX` in `/etc/default/grub`. 

```bash
GRUB_CMDLINE_LINUX="ipv6.disable_ipv6=1 net.ifnames=0 biosdevname=0 video=Virtual-1:1920x1080"
```

Finally, update the configuration with `sudo update-grub`.