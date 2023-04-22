#!/bin/bash
# remove the default firefox (from fedora) in favor of the flatpak
rpm-ostree override remove firefox firefox-langpacks
# remove default GNOME Extensions app in favor of the Extension Manager flatpak
rpm-ostree override remove gnome-extensions-app

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

echo "-- Setting themes --"
gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita'
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'

# install yafti to install flatpaks on first boot, https://github.com/ublue-os/yafti
pip install --prefix=/usr yafti

# add a package group for yafti using the packages defined in recipe.yml
yq -i '.screens.applications.values.groups.Custom.description = "Flatpaks defined by the image maintainer"' /etc/yafti.yml
yq -i '.screens.applications.values.groups.Custom.default = true' /etc/yafti.yml
flatpaks=$(yq '.flatpaks[]' < /tmp/ublue-recipe.yml)
for pkg in $(echo -e "$flatpaks"); do \
    yq -i ".screens.applications.values.groups.Custom.packages += [{\"$pkg\": \"$pkg\"}]" /etc/yafti.yml
done
