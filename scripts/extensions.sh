#!/bin/bash
echo "-- Removing the built in GNOME Extensions app in favor of the better flatpak --"
rpm-ostree override remove gnome-extensions-app
