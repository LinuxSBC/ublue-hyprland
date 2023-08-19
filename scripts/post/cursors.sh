#!/bin/bash
set -oue pipefail

# Download latest version of Adwaita icons
git clone https://gitlab.gnome.org/GNOME/adwaita-icon-theme.git /tmp/adwaita-icon-theme

# Replace current Adwaita icons with new ones
rm -rf /usr/share/icons/Adwaita
cp -r /tmp/adwaita-icon-theme/Adwaita /usr/share/icons/Adwaita

# Clean up
rm -rf /tmp/adwaita-icon-theme
