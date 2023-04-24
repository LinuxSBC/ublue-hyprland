#!/bin/bash
# remove the default firefox (from fedora) in favor of the flatpak
rpm-ostree override remove firefox firefox-langpacks

echo "-- Installing adw-gtk3 COPR repo --"
curl https://copr.fedorainfracloud.org/coprs/nickavem/adw-gtk3/repo/fedora-${FEDORA_MAJOR_VERSION}/nickavem-adw-gtk3-fedora-${FEDORA_MAJOR_VERSION}.repo > /etc/yum.repos.d/nickavem-adw-gtk3-fedora-${FEDORA_MAJOR_VERSION}.repo

echo "-- Installing MoreWaita COPR repo --"
curl https://copr.fedorainfracloud.org/coprs/dusansimic/themes/repo/fedora-${FEDORA_MAJOR_VERSION}/dusansimic-themes-fedora-${FEDORA_MAJOR_VERSION}.repo > /etc/yum.repos.d/dusansimic-themes-fedora-${FEDORA_MAJOR_VERSION}.repo

echo "-- Installing RPMs defined in recipe.yml --"
rpm_packages=$(yq '.rpms[]' < /tmp/ublue-recipe.yml)
for pkg in $(echo -e "$rpm_packages"); do \
    echo "Installing: ${pkg}" && \
    rpm-ostree install $pkg; \
done
echo "---"

echo "-- Configuring Distrobox --"
mkdir -p /etc/distrobox
echo "container_image_default=\"registry.fedoraproject.org/fedora-toolbox:$(rpm -E %fedora)\"" >> /etc/distrobox/distrobox.conf

echo "-- Updating dconf to load theme changes --"
dconf update

echo "-- Removing the built in GNOME Extensions app in favor of the better flatpak --"
rpm-ostree override remove gnome-extensions-app
echo "-- Removing gnome-terminal in favor of the BlackBox flatpak --"
rpm-ostree override remove gnome-terminal gnome-terminal-nautilus

echo "-- Installing OpenInBlackBox for Nautilus integration --" # Switch to nautilus-open-any-terminal?
if [[ ! -d /usr/share/nautilus-python/extensions/ ]]; then
    mkdir -v -p /usr/share/nautilus-python/extensions/
fi
curl https://raw.githubusercontent.com/ppvan/OpenInBlackBox/main/blackbox_extension.py > /usr/share/nautilus-python/extensions/blackbox_extension.py

echo "-- Setting BlackBox as default terminal --"
tee /usr/bin/blackbox <<EOF
#!/bin/bash
flatpak run com.raggesilver.BlackBox \$@
EOF
chmod +x /usr/bin/blackbox
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/blackbox 50
update-alternatives --set x-terminal-emulator /usr/bin/blackbox

curl https://github.com/Vladimir-csp/xdg-terminal-exec/raw/master/xdg-terminal-exec > /usr/bin/xdg-terminal-exec
chmod +x /usr/bin/xdg-terminal-exec

echo "-- Installing yafti to install Flatpaks on boot --"
# install yafti to install flatpaks on first boot, https://github.com/ublue-os/yafti
pip install --prefix=/usr yafti

# add a package group for yafti using the packages defined in recipe.yml
yq -i '.screens.applications.values.groups.Custom.description = "Flatpaks defined by the image maintainer"' /etc/yafti.yml
yq -i '.screens.applications.values.groups.Custom.default = true' /etc/yafti.yml
flatpaks=$(yq '.flatpaks[]' < /tmp/ublue-recipe.yml)
for pkg in $(echo -e "$flatpaks"); do \
    yq -i ".screens.applications.values.groups.Custom.packages += [{\"$pkg\": \"$pkg\"}]" /etc/yafti.yml
done
