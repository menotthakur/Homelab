#!/bin/bash

set -e

echo "Updating packages..."
sudo apt update

echo "Installing prerequisites..."
sudo apt install -y \
ca-certificates \
curl \
gnupg \
lsb-release

echo "Installing Docker..."
curl -fsSL https://get.docker.com | sudo sh

echo "Adding current user to docker group..."
sudo usermod -aG docker $USER

echo "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Docker version:"
docker --version || true

echo ""
echo "IMPORTANT:"
echo "Logout and login again before using docker without sudo."
echo ""

echo "Testing Docker..."
sudo docker run hello-world

echo "Done."
