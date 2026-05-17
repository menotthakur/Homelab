#!/bin/bash

set -e

SWAP_SIZE="5G"

echo "Current swap:"
swapon --show

echo "Disabling old swap..."
sudo swapoff -a

echo "Removing old swap file..."
sudo rm -f /swap.img
sudo rm -f /swapfile

echo "Creating new swap..."
sudo fallocate -l $SWAP_SIZE /swapfile

echo "Setting permissions..."
sudo chmod 600 /swapfile

echo "Formatting swap..."
sudo mkswap /swapfile

echo "Enabling swap..."
sudo swapon /swapfile

echo "Persisting in fstab..."

if ! grep -q "/swapfile" /etc/fstab; then
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

echo "Swap status:"
swapon --show

echo "Memory status:"
free -h

echo "Done."
