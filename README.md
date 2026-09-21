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

- Over your pc open your terminal and insert: ``ssh mobile@<Your iPhone IP>`` then when prompted, create (or not) a simple password for your connection

- Exit the `ssh` environment 

- Now after testing the connection, do on your terminal: `scp /path/to/resize_apfs mobile@<Your iPhone IP>:/var/jb/var/mobile` for the **resize_apfs** tool

- The same for **gdisk** `scp /path/to/gdisk mobile@<Your iPhone IP>:/var/jb/var/mobile`

- Now we are gonna be moving them internally to /var/jb/var/bin with: `ssh mobile@<Your iPhone IP>` then `sudo mv /var/jb/var/mobile/resize_apfs /var/jb/var/bin/` same for **gdisk** with `sudo mv /var/jb/var/mobile/gdisk /var/jb/var/bin/` now `chmod +x /var/jb/var/bin/resize_apfs` and `chmod +x /var/jb/var/bin/gdisk`

### Resizing your partition

This part really depends on how much storage you'll give to linux, mind you the number is in bytes but in binary system, so for example if I want **9 GB** for linux then it would be `sudo resize_apfs disk0s1 60129542144`
>Cuz **64 GB - 9 GB = 56 GB**, 64 GB being your iPhone storage so **64 - 9 = 56  -->  56 × 1024³ = 60129542144 bytes**
After that the device should recognize the storage as 56 GB successfully.


## Formatting partition
### **⚠️ This section requires extra attention as any misconfiguration may BRICK UR DEVICE forever. ever.**

We just need to create the partition correctly and format it, type: `sudo gdisk /dev/rdisk0`

This should appear:

---

`GPT fdisk (gdisk) version 1.0.10`

`Warning: Devices opened with shared lock will not have their
partition table automatically reloaded!
Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present`

`Found valid GPT with protective MBR; using GPT.`

`Command (? for help):`

---
Then: `d` --> `n` --> `1` --> `6` --> Now take the number in bytes you used to format the partition, in our example 60129542144 --> `60129542144` --> `AF0A`

After that the iOS partition will be declared the same size we resized it, but now u freed the linux storage

Now for the new partition: `n` --> `2` --> `*Enter` --> `+9G` --> `8305` 

Then: `c`--> `1` --> `Container` ---> `c` --> `2` --> `linux`

Now `p` to make to make sure its all good, you should see 2 partitions, **1 = Container**, **2 = linux**
Then after REALLY making sure, write to disk with `w` and confirm.





