# Installing Arch Linux on iPhone 8 natively
### This will guide you through the partition scheme to the boot and DE setup.
_- Currently only for iPhone 8_

---
Starting up you wanna have the following prerequisites:
- A ***jailbroken*** iPhone 8 or 8 Plus (duh)
- A good USB cable (preferably on your USB 2.0 pc port)
- A good mental sanity

## Resizing APFS and formatting partition
- To start, grab the **resize_apfs** and **gdisk** utilities: [here](https://nightly.link/hoolocklinux/docs/workflows/build/master/hoolock-support-iphoneos.zip)

- Next, on iPhone, you wanna install the `openssh` package from Sileo and then look up your current iPhone IP in wi-fi settings

- Over your pc open your terminal and insert: `ssh mobile@<Your iPhone IP>` then when prompted, `yes`, and create a simple password for your connection

- Exit the `ssh` environment 

- Now after testing the connection, do on your terminal for the **resize_apfs** tool:

```
$ ~ scp /path/to/resize_apfs mobile@<Your iPhone IP>:/var/jb/var/mobile
```

- The same for **gdisk**
```
$ ~ scp /path/to/gdisk mobile@<Your iPhone IP>:/var/jb/var/mobile`
```

- Now we are gonna be moving them internally to /var/jb/var/bin and give them permissions with: `ssh mobile@<Your iPhone IP>` then 
```
#~ sudo mv /var/jb/var/mobile/resize_apfs /var/jb/var/bin/
#~ sudo mv /var/jb/var/mobile/gdisk /var/jb/var/bin/
#~ chmod +x /var/jb/var/bin/resize_apfs
#~ chmod +x /var/jb/var/bin/gdisk
```

### Resizing your partition

This part really depends on how much storage you'll give to linux, mind you the number is in bytes but in binary system, so for example if I want **9 GB** for linux then it would be 
```
sudo resize_apfs disk0s1 60129542144
```
>Cuz **64 GB - 9 GB = 56 GB**, 64 GB being your iPhone storage so **56 × 1024³ = 60129542144 bytes** 

After that the iPhone should recognize the storage as resized system successfully.


### Formatting partition
***⚠️ This section requires extra attention as any misconfiguration may BRICK UR DEVICE forever. ever.***

We just need to create the partition correctly and format it, type: `sudo gdisk /dev/rdisk0`
> ### Some cases it might be necessary to run it inside the directory, if so do: `cd /var/jb/var/bin && sudo ./gdisk /dev/rdisk0` this should work for resize_apfs too

This should appear:

---

```
GPT fdisk (gdisk) version 1.0.10

Warning: Devices opened with shared lock will not have their
partition table automatically reloaded!
Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present

Found valid GPT with protective MBR; using GPT.

Command (? for help):
```

---
Then do:

```
d
1
n
1
6
```

>Now take the number in bytes you used to format the partition, in our example 60129542144 --> 
```
60129542144 
AF0A
```

After that the iOS partition will be declared the same size we resized it, but now u freed the linux space

Now for the new partition: 

```
n
2
*Enter*
+9G
8305
``` 

Then:
```
c
1
Container
c
2
linux
```

Now `p` to make to make sure its all good, you should see 2 partitions, **1 = Container**, **2 = linux**
Then after **REALLY** making sure, write to disk with `w` and confirm.

## Building the kernel

We will be using the Hoolock Linux kernel for this, follow their official guide [here](https://github.com/HoolockLinux/docs/blob/master/tutorials/SETUP.md)

We will also need the m1n1 bootloader, guide [here](https://github.com/HoolockLinux/m1n1)
 
---

After you compiled the hoolock linux kernel, the Image.gz will be found at `/path/to/hoolock-linux/arch/arm64/boot/`

Then as said we will used the pongoOS method, follow guide JUST UNTIL **Building pongoterm** (!!!), guide [here](https://github.com/HoolockLinux/docs/blob/master/tutorials/SETUP_pongoOS.md)

## Making hoolock linux environment

### In this part we will need to boot into the raw linux kernel, to make some configurations and fixes

- Now with all the files necessary to boot we need to build the **m1n1-hoolock.bin** binary like this:
```
$ ~ cat /path/to/m1n1/build/m1n1.bin <(echo 'chosen.bootargs=earlycon rw loglevel=7')  \
	/path/to/hoolock-linux/arch/arm64/boot/dts/apple/*.dtb \
	/path/to/hoolock-linux/arch/arm64/boot/Image.gz  \
	/path/to/initramfs.gz  > m1n1-hoolock.bin
```
- Then `pwd` just to see where it is.

- Now we need palera1n
```
$ ~ /bin/sh -c "$(curl -fsSL https://static.palera.in/scripts/install.sh)" 
```
### Booting the Linux kernel
Now in the boot process, we're booting first into pongoOS environment:
```
$ ~ PALERA1N_BYPASS_PASSCODE_CHECK=1 palera1n -lp -k /path/to/pongoOS/build/Pongo.bin
```
Then upload the newly created **m1n1-hoolock.bin**:
```
$ ~ cd /pongoOS/scripts
$ ~ printf '/send /path/to/m1n1-hoolock.bin\nbootm\n' | ./pongoterm
```
Then the device should boot into the Linux kernel and open a `telnet` communication protocol, leave the iPhone aside for now

---

### Now we need the **Arch Linux** latest arm64 release in [here](https://archlinuxarm.org/about/downloads)
`* The ARMv8 AArch64 Multi-platform to be exact`
- Then decompress the downloaded file your desktop 
```
$ ~ mkdir archlinux
$ ~ sudo bsdtar -xpf /path/to/ArchLinuxARM-aarch64-latest.tar.gz -C archlinux
```
Should look something like this: 

<img width="769" height="549" alt="image" src="https://github.com/user-attachments/assets/ec950f05-e15b-400d-ae46-a9a91c663afd" />


Now we are going to copy **qemu-user-static** and **binfmt-support** for running chroot in our host pc
```
Install if not installed:

$ ~  sudo apt install qemu-user-static binfmt-support

# Fedora
$ ~ sudo dnf install -y qemu-user-static

# Arch
$ ~ sudo pacman -Syu qemu-user-static qemu-user-static-binfmt

Then copy it to the rootfs -->

$ ~ sudo cp /usr/bin/qemu-aarch64-static archlinux/usr/bin/
```
Then after that lets run chroot and 
```
$ ~ sudo chroot archlinux /usr/bin/qemu-aarch64-static /bin/bash
```

>You should see this:
[root@"Your user"-01 /]# _

Now setup:
```
# passwd
# pacman-key --init
# pacman-key --populate
# pacman -Rdd linux-aarch64
```
Now **exit** chroot environment and compact it back to send it over to the iPhone later
```
$ ~ sudo tar czf archlinux-ready.tar.gz -C alarm-root .
```

## Sending the Arch Linux rootfs over to the iPhone and fixing stuff
Okay now assuming youve already booted and now have the Arch Linux rootfs we're like halfway thru!

To mount the partition, just:
```
~ # mkdir arch
~ # mount /dev/nvme0n1p2 /arch
```

So now that youre inside the Linux in the iPhone, just:
```
$ ~ telnet 172.16.42.1
```
And then youre inside the Linux, from here we're going to pull the rootfs to the partition, for that we are going to push it via USB Mass Storage, the iPhone would be like a USB driver for our host

For that we want to make this is script inside linux
```
cat > /enable-ms.sh << 'EOF' \
#!/bin/sh \
echo "" > /config/usb_gadget/g1/UDC \
mkdir -p /config/usb_gadget/g1/functions/mass_storage.usb0 \
echo /dev/nvme0n1p2 > /config/usb_gadget/g1/functions/mass_storage.usb0/lun.0/file \
ln -sf /config/usb_gadget/g1/functions/mass_storage.usb0
/config/usb_gadget/g1/configs/c.1/ \
UDC_DEV=$(ls /sys/class/udc | head -1) \
echo "$UDC_DEV" > /config/usb_gadget/g1/UDC \
EOF
```
```
~ # chmod +x /tmp/enable-ms.sh
~ # nohup /tmp/enable-ms.sh > /tmp/enable-ms.log 2>&1 &
```

If the script ran successfully a new device will pop up on your screen

- Now on the host side, it should appear a new USB drive, check it with `lsblk`, and now the transfer part, open the device, then decompress the ****archlinux-ready.tar.gz**** into it
```
$ ~ sudo mkdir -p /mnt/archlinux
$ ~ sudo mount /dev/sdX /mnt/archlinux
$ ~ sudo tar xzf archlinux-ready.tar.gz -C /mnt/archlinux
```
---
**Then we just have some USB fixes to be done, for that:**
- Grab the **usb-setup.sh** script i did and copy it to `/usr/local/bin` then give it permissions with
```
chmod +x /mnt/archlinux/usr/local/bin/usb-setup.sh
```
- Now for the **usb-device.service**, copy it over to `/etc/systemd/system/`, then:
```
systemctl enable usb-gadget.service
```

## ***After this it should be all set for the Arch Linux boot!!***

### Booting Arch Linux
- By now you have only the **m1n1-hoolock.bin** now we'll make the **m1n1-arch.bin** binary to boot into arch

Now this, on your host machine:
```
$ ~ cat /path/to/m1n1/build/m1n1.bin \
    <(echo 'chosen.bootargs=root=/dev/nvme0n1p2 rw rootwait init=/bin/sh') \
    /path/to/hoolock-linux/arch/arm64/boot/dts/apple/*.dtb \
    /path/to/hoolock-linux/arch/arm64/boot/Image.gz \
    > m1n1-arch.bin
```
### Now that you created the **Arch Linux** boot instruction

Boot it the same way as booting **m1n1-hoolock.bin**:
```
$ ~ PALERA1N_BYPASS_PASSCODE_CHECK=1 palera1n -lp -k /path/to/pongoOS/build/Pongo.bin
```
Now send the Arch binary
```
$ ~ cd /pongoOS/scripts
$ ~ printf '/send /path/to/m1n1-hoolock.bin\nbootm\n' | ./pongoterm
```
...










