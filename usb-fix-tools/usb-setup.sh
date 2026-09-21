CONFIGFS="/sys/kernel/config/usb_gadget"
HOST_IP="172.16.42.1"

for i in $(seq 1 10); do
    [ -d "$CONFIGFS" ] && break
    sleep 0.5
done

if [ ! -d "$CONFIGFS" ]; then
    exit 1
fi

UDC_DEV="$(ls /sys/class/udc | head -1)"
if [ -z "$UDC_DEV" ]; then
    exit 1
fi

GADGET="$CONFIGFS/g1"

if [ -d "$GADGET" ]; then
    echo "" > "$GADGET/UDC" 2>/dev/null || true
fi

mkdir -p "$GADGET"
echo "0x05ac" > "$GADGET/idVendor"
echo "0x4142" > "$GADGET/idProduct"

mkdir -p "$GADGET/strings/0x409"
echo "HoolockLinux"                              > "$GADGET/strings/0x409/manufacturer"
echo "$(cat /proc/device-tree/serial-number 2>/dev/null || echo unknown)" > "$GADGET/strings/0x409/serialnumber"
echo "HoolockLinux USB Device"                    > "$GADGET/strings/0x409/product"

NET_FUNC="ncm.usb0"
if ! mkdir -p "$GADGET/functions/$NET_FUNC" 2>/dev/null; then
    NET_FUNC="rndis.usb0"
    mkdir -p "$GADGET/functions/$NET_FUNC"
fi

mkdir -p "$GADGET/functions/acm.usb0"

mkdir -p "$GADGET/configs/c.1/strings/0x409"
echo "USB network+serial" > "$GADGET/configs/c.1/strings/0x409/configuration"

ln -sf "$GADGET/functions/$NET_FUNC"    "$GADGET/configs/c.1/"
ln -sf "$GADGET/functions/acm.usb0"     "$GADGET/configs/c.1/"

echo "$UDC_DEV" > "$GADGET/UDC"

sleep 1

IFACE="$(cat "$GADGET/functions/$NET_FUNC/ifname" 2>/dev/null || echo usb0)"
ip addr add "$HOST_IP/24" dev "$IFACE" 2>/dev/null || true
ip link set "$IFACE" up

echo "usb config done: interface=$IFACE, ip=$HOST_IP"
