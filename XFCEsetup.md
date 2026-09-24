# Installing XFCE
### We will use XFCE cuz its lightweight and enough for the CPU to process everything at once

---
Now do:
```
/ ~ sudo pacman -S xorg-server xfce4 xfce4-goodies
/ ~ echo "exec startxfce4" > ~/.xinitrc
```
But notice then when you try start the environment it will give you an error because we are controlling it remotely, next do:
```
/ ~ sudo nano /etc/X11/Xwrapper.config

- Then add
                               
allowed_users=anybody
needs_root_rights=yes
```
Done, after that you should be able to start it again normally with
```
/ ~ startx

- Or hidden process with:

/ ~ startx > /dev/null 2>&1 &
```
## Setting up VNC
For this i recommend using `x11vnc` so install it 
```
sudo pacman -S x11vnc
```
Then just 
```
/ ~ x11vnc

-Or hidden:

x11vnc > /dev/null 2>&1 &
```
Now if youre on Linux i recommend downloading **Remmina** VNC viewer, on macOS the finder option with `⌘ + K` works perfectly fine
- Your configs on **Remmina** should look like this:

<img width="781" height="549" alt="image" src="https://github.com/user-attachments/assets/2430a7ab-488b-4e5d-8cb3-56aae3043522" />

---

-On macOS like this:

>I recommend you change screen orientation and note that if u do this the x11vnc may crash, but just run it again

And then it should connect

***Thats it, enjoy your linux! :)***

























