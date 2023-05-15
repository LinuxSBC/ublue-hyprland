#!/bin/bash
echo "-- Removing gnome-terminal in favor of the BlackBox flatpak --"
rpm-ostree override remove gnome-terminal gnome-terminal-nautilus

echo "-- Installing OpenInBlackBox for Nautilus integration --"
if [[ ! -d /usr/share/nautilus-python/extensions/ ]]; then
    mkdir -v -p /usr/share/nautilus-python/extensions/
fi
curl https://raw.githubusercontent.com/ppvan/OpenInBlackBox/main/blackbox_extension.py > /usr/share/nautilus-python/extensions/blackbox_extension.py

echo "-- Setting BlackBox as default terminal --"
tee /usr/bin/blackbox <<EOF
#!/bin/bash
/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=blackbox com.raggesilver.BlackBox "\$@"
EOF
chmod +x /usr/bin/blackbox
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/blackbox 50
update-alternatives --set x-terminal-emulator /usr/bin/blackbox

curl https://raw.githubusercontent.com/Vladimir-csp/xdg-terminal-exec/master/xdg-terminal-exec > /usr/bin/xdg-terminal-exec
chmod +x /usr/bin/xdg-terminal-exec
