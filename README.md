# Installing Arch Linux on iPhone 8 natively
### This will guide you through the partition scheme to the boot and DE setup.
_- Currently only for iPhone 8_

---
Starting up you wanna have the following prerequisites:
- A ***jailbroken*** iPhone 8 or 8 Plus (duh)
- A good USB cable (preferably on your USB 2.0 pc port)
- Palera1n installed (for pongoOS method), guide here (skip the building m1n1 section for now): [here](https://github.com/HoolockLinux/docs/blob/master/tutorials/SETUP_pongoOS.md)

## Resizing APFS and formatting partition
- To start grab the **resize_apfs** and **gdisk** utilities: [here](https://nightly.link/hoolocklinux/docs/workflows/build/master/hoolock-support-iphoneos.zip)

- Next you wanna install the `openssh` package from Sileo and look up your current iPhone IP in wi-fi settings

- Over your pc open your terminal and insert: ``ssh mobile@<Your iPhone IP>`` then when prompted, create (or not) a simple password for your connection

- Exit the `ssh` environment 

- Then after testing the `ssh` connection, do: `scp /path/to/resize_apfs mobile@<Your iPhone IP>:/var/jb/var/mobile` for the **resize_apfs** tool

- The same for **gdisk** `scp /path/to/gdisk mobile@<Your iPhone IP>:/var/jb/var/mobile`

- 

