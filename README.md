<img src="https://archlinux.org/static/logos/archlinux-logo-dark-1200dpi.png" width="200">  




# Installing Arch Linux on iPhone 8
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
- Then decompress the downloaded file your desktop with
```
$ ~ mkdir archlinux
$ ~ sudo bsdtar -xpf /path/to/ArchLinuxARM-aarch64-latest.tar.gz -C archlinux
```
Should look something like this: 

<img width="769" height="549" alt="image" src="https://github.com/user-attachments/assets/ec950f05-e15b-400d-ae46-a9a91c663afd" />


Now we are going to copy **qemu-user-static** and **binfmt-support** to run the ARM64 chroot in our host pc

```
Install:

$ ~  sudo apt install qemu-user-static binfmt-support

# Fedora
$ ~ sudo dnf install -y qemu-user-static

# Arch
$ ~ sudo pacman -Syu qemu-user-static qemu-user-static-binfmt

Then copy it to the rootfs -->

$ ~ sudo cp /usr/bin/qemu-aarch64-static archlinux/usr/bin/
```
Then after that lets mount and run chroot:
```
$ ~ sudo mount -t proc /proc archlinux/proc
$ ~ sudo mount --rbind /sys archlinux/sys
$ ~ sudo mount --rbind /dev archlinux/dev
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
$ ~ sudo tar czf archlinux-ready.tar.gz -C archlinux .
```

## Sending the Arch Linux rootfs over to the iPhone and fixes
Okay now assuming youve already booted and now have the Arch Linux rootfs we're like halfway thru!

***Make sure u run this inside the iPhone shell with*** `telnet 172.16.42.1` !!

To mount the Arch linux designated partition, just:
```
~ # mkdir arch
~ # mount /dev/nvme0n1p2 /arch
```
---

And then youre inside the Linux, from here we're going to pull the rootfs to the partition, for that we are going to push HTTP server, the iPhone would pull it via `wget`

- Firstly open your settings and go to the Network part
- Search for IPv4 and switch from *Automatic* to *Manual* and put the address as `172.16.42.2` and submask `255.255.255.0`

Now open another terminal instance in host, then we want to go to the compressed final rootfs
```
$ ~ cd /path/to/archlinux-ready.tar.gz
/ ~ python3 -m http.server 8000
```
==>
```
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```
Now back on the iPhone shell 
```
~ # wget -O- http://172.16.42.2:8000/alarm-ready.tar.gz | tar -xz -C /arch
```
==>
```
Connecting to 172.16.42.2:8000 (172.16.42.2:8000)
writing to stdout
-                    100% |********************************|  673M  0:00:00 ETA
written to stdout
```
Now check it out with `ls /arch`

---

## **USB halting boot fix**
When you boot the Arch Linux it may get stuck while boothing, this happens cuz sometimes `g_multi` kernel module fails to identify our USB connection, to fix grab the `usb-device.service` [here](https://raw.githubusercontent.com/aeosxii/iarch/refs/heads/main/usb-fix-tools/usb-device.service) and the `usb-setup.sh` [here](https://raw.githubusercontent.com/aeosxii/iarch/refs/heads/main/usb-fix-tools/usb-setup.sh)

Use the `wget` method to pull them inside the rootfs
```
# Host machine

$ ~ cd /path/to/usb-fix
/ ~ python3 -m http.server 8000
```
```
# iPhone shell

~ # wget http://172.16.42.2:8000/usb-setup.sh -O /arch/usr/local/bin/usb-setup.sh
~ # wget http://172.16.42.2:8000/usb-device.service -O /arch/etc/systemd/system/usb-device.service
```
Now to make sure they work
```
~ # chmod +x /arch/usr/local/bin/usb-setup.sh

~ # mount -t proc /proc arch/proc
~ # mount --rbind /sys arch/sys
~ # mount --rbind /dev arch/dev
~ # chroot arch /bin/bash

/# systemctl enable usb-gadget.service
/# systemctl enable serial-getty@ttyGS0.service
/# exit
```

---

### ***After this all should be ready to boot Arch Linux!***

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

### Control the linux
---

Install the `screen` tool with 
```
$ ~ sudo apt install screen 
$ ~ sudo usermod -aG dialout $USER
```
Then tap into the device with
```
sudo screen /dev/ttyACM0 115200
```
### Setup internet connection
- On the host, you wann grab the iPhone serial identifier with:
```
ip a
```
It should look *somewhat* similar to this
```
21: enx0eecc074f34c: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 0e:ec:c0:74:f3:4c brd ff:ff:ff:ff:ff:ff
    inet 172.16.42.2/24 brd 172.16.42.255 scope global enx0eecc074f34c
       valid_lft forever preferred_lft forever
```
And here in that case we see the device identifier is `enx0eecc074f34c`, so now run
```
$ ~ sudo ifconfig "Your identifier" 172.16.42.2 netmask 255.255.255.0
$ ~ sudo sysctl -w net.ipv4.ip_forward=1
```
- On the Arch side
```
/ ~ ip route add default via 172.16.42.2
```
Then update everything with
```
/ ~ pacman -Syu --disable-sandbox 
```

Then done! 

---
*This project was compiled and tested on the Linux Kernel version 7.3.0*

![HoolockLinux](https://img.shields.io/badge/HoolockLinux-000000?style=flat&logo=linux&logoColor=white)  |  ![iPhone 8](https://img.shields.io/badge/iPhone_8-A2AAAD?style=flat&logo=apple&logoColor=white)  |  ![Arch Linux!](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)










