# Installing Arch Linux on iPhone 8 natively
### This will guide you through the partition scheme to the boot and DE setup.
_- Currently only for iPhone 8_

---
Starting up you wanna have the following prerequisites:
- A ***jailbroken*** iPhone 8 or 8 Plus (duh)
- A good USB cable (preferably on your USB 2.0 pc port)
- Palera1n installed (we will use pongoOS method), guide here (**skip the building m1n1 section for now**): [here](https://github.com/HoolockLinux/docs/blob/master/tutorials/SETUP_pongoOS.md)

## Resizing APFS and formatting partition
- To start, grab the **resize_apfs** and **gdisk** utilities: [here](https://nightly.link/hoolocklinux/docs/workflows/build/master/hoolock-support-iphoneos.zip)

- Next, on iPhone, you wanna install the `openssh` package from Sileo and then look up your current iPhone IP in wi-fi settings

- Over your pc open your terminal and insert: `ssh mobile@<Your iPhone IP>` then when prompted, create (or not) a simple password for your connection

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

This part really depends on how much storage you'll give to linux, mind you the number is in bytes but in binary system, so for example if I want **9 GB** for linux then it would be `sudo resize_apfs disk0s1 60129542144`
>Cuz **64 GB - 9 GB = 56 GB**, 64 GB being your iPhone storage so **56 × 1024³ = 60129542144 bytes** 

After that the iPhone should recognize the storage as resized system successfully.


## Formatting partition
### **⚠️ This section requires extra attention as any misconfiguration may BRICK UR DEVICE forever. ever.**

We just need to create the partition correctly and format it, type: `sudo gdisk /dev/rdisk0`
>Some cases it might be necessary to run it inside the directory, if so do: `cd /var/jb/var/mobile && sudo ./gdisk`

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
n
1
6
```

Now take the number in bytes you used to format the partition, in our example 60129542144 --> 
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

Then as said we will used the pongoOS method, follow guide until **# Building pongoterm**, guide [here](https://github.com/HoolockLinux/docs/blob/master/tutorials/SETUP_pongoOS.md)

## Making boot binary

Now with all the files neccessary to boot we need to build the **m1n1-linux.bin** like this:
```
cat /path/to/m1n1/build/m1n1.bin <(echo 'chosen.bootargs=<kernel command line here>')  \
	/path/to/hoolock-linux/arch/arm64/boot/dts/apple/*.dtb \
	/path/to/hoolock-linux/arch/arm64/boot/Image.gz  \
	/path/to/initramfs.gz  > m1n1-linux.bin
```








