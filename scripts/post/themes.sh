#!/bin/bash
set -oue pipefail

echo "-- Updating dconf to load theme changes --"
dconf update
