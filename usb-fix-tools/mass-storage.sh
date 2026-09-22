#!/bin/sh
echo "" > /config/usb_gadget/g1/UDC
mkdir -p /config/usb_gadget/g1/functions/mass_storage.usb0
echo /dev/nvme0n1p2 >  /config/usb_gadget/g1/functions/mass_storage.usb0/lun.0/filee
ln -sf /config/usb_gadget/g1/functions/mass_storage.usb0 /config/usb_gadget/g1/configs/c.1/
UDC_DEV=$(ls /sys/class/udc | head -1)
echo "$UDC_DEV" > /config/usb_gadget/g1/UDC
