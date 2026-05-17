# Homelab Setup & Troubleshooting Journey

## Overview

This document contains the complete journey of setting up a personal homelab server using an old laptop running Ubuntu Server.

The setup included:

* Ubuntu installation
* Networking setup
* SSH troubleshooting
* Wi-Fi instability debugging
* Ethernet migration
* Static IP configuration
* Swap configuration
* Docker installation
* Initial homelab infrastructure preparation

---

# Initial Hardware Setup

## Main Laptop

Used for:

* SSH access
* Managing homelab
* Development
* Internet access

## Homelab Server

Old HCL laptop:

* ~298 GB HDD
* 2 GB RAM
* Ubuntu installed
* Initially Ubuntu Desktop
* Later migrated to Ubuntu Server

---

# Phase 1 — Initial Ubuntu Desktop Setup

Initially Ubuntu Desktop (GNOME UI) was installed.

Problems observed:

* System hangs/freezes
* High RAM usage
* Wi-Fi instability
* SSH inaccessible after reboot
* Overnight disconnections

Important realization:
Ubuntu Desktop behaves like a laptop OS, not a server OS.

Desktop distributions:

* suspend aggressively
* use Wi-Fi power saving
* run heavy GUI services
* are less stable on low-RAM systems

---

# Phase 2 — Understanding Networking Basics

Important networking concepts learned:

## Private IP

Example:
192.168.1.8

Used only inside home network.

## Public IP

ISP-assigned internet-facing IP.

## Broadcast Address

Example:
192.168.1.255

Initially SSH was attempted against:
ssh user@192.168.1.255

This failed because .255 is the broadcast address, not a device.

## Router/Gateway

Usually:
192.168.1.1

Acts as:

* internet gateway
* NAT device
* traffic controller

## ARP

Address Resolution Protocol.

Used by devices to discover MAC addresses of nearby devices.

A major issue later turned out to be ARP/device visibility failure.

---

# Phase 3 — SSH Setup

Installed OpenSSH server:

sudo apt install openssh-server -y

Enabled SSH:

sudo systemctl enable ssh
sudo systemctl start ssh

Verified:

sudo systemctl status ssh

Successfully SSHed from Windows:

ssh [thakur@192.168.1.X](mailto:thakur@192.168.1.X)

---

# Phase 4 — Initial Wi-Fi Instability

Observed symptoms:

* SSH timeouts
* ping failures
* overnight disconnects
* intermittent LAN visibility

Ping output:

Reply from 192.168.1.4: Destination host unreachable

Important discovery:
Internet sometimes worked while LAN communication failed.

This indicated:

* ARP problems
* Wi-Fi instability
* client isolation possibilities

---

# Phase 5 — Router Isolation Issue

Initially one router caused:

* device-to-device communication failure
* SSH failures
* ping failures

Internet still worked.

Meaning:
Device -> Router -> Internet worked
BUT
Device -> Device communication failed.

Most likely reasons:

* AP isolation
* client isolation
* buggy router firmware

Changing router fixed communication instantly.

Major lesson:
Networking infrastructure matters.

---

# Phase 6 — Diagnosing Overnight Disconnects

Even after fixing router issue:

* overnight disconnects continued
* SSH inaccessible next morning

Logs inspected using:

sudo journalctl -u NetworkManager

Useful grep patterns:

sudo journalctl -u NetworkManager | grep -Ei "disconnect|deauth|fail|error|timeout"

Kernel and supplicant logs revealed:

* supplicant-failed
* disconnect loops
* Wi-Fi instability

Important realization:
The issue was not Docker or SSH.

Root issue:

* unstable Wi-Fi stack
* old laptop Wi-Fi hardware
* Ubuntu Desktop power management

---

# Phase 7 — Migration to Ubuntu Server

Decision made:
Move from Ubuntu Desktop to Ubuntu Server.

Reasons:

* lower RAM usage
* fewer services
* no GNOME overhead
* no desktop sleep logic
* better server stability

Results:

* significantly cleaner environment
* lower memory usage
* improved responsiveness
* better operational behavior

---

# Phase 8 — Wi-Fi Setup Challenges on Ubuntu Server

Ubuntu Server initially lacked:

* NetworkManager
* nmcli
* nmtui
* iwlist

Manual Wi-Fi configuration attempted using:

* wpa_supplicant
* manual interface setup

Commands used:

sudo wpa_passphrase "SSID" "PASSWORD" > wifi.conf

sudo wpa_supplicant -B -i wlp1s0 -c wifi.conf

Issues encountered:

* DHCP tooling missing
* unstable wireless connectivity
* routing issues

---

# Phase 9 — Ethernet-Based Recovery

A LAN cable was connected between:

* main laptop
* Ubuntu Server

Windows internet sharing was enabled.

This created network:
192.168.137.x

Manual Linux networking setup performed:

sudo ip addr add 192.168.137.2/24 dev enp4s0

sudo ip route add default via 192.168.137.1

DNS fixed manually:

echo "nameserver 8.8.8.8" > /etc/resolv.conf

This restored internet connectivity.

Major lesson:
Ethernet is dramatically more stable than Wi-Fi for servers.

---

# Phase 10 — Installing NetworkManager

After internet recovery:

Installed:

* network-manager
* nmcli
* nmtui

This simplified networking management significantly.

---

# Phase 11 — Final Stable Architecture

Final decision:
Connect server directly to router using Ethernet.

Architecture:

Main Laptop
|
Wi-Fi/LAN
|
Router
|
Ethernet
|
Ubuntu Server

Benefits:

* stable networking
* reliable SSH
* no Wi-Fi power-saving issues
* lower latency
* production-like setup

---

# Phase 12 — Static IP Configuration

Static IP configured via:
Router DHCP reservation.

Chosen IP:
192.168.1.69

MAC Address:
00:23:8b:77:b1:26

Benefits:

* stable SSH endpoint
* predictable service access
* easier monitoring
* easier Docker/service management

---

# Phase 13 — Understanding LVM Storage

Observed:

* only 100 GB mounted
* total disk actually ~298 GB

Investigation using:

lsblk

df -h

Discovered:
Ubuntu installer created:

* LVM volume group
* only partial allocation to root logical volume

Root LV:
/dev/mapper/ubuntu--vg-ubuntu--lv

Remaining space available inside VG.

Solution planned:

sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv

sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

Important lesson:
LVM allows flexible disk resizing later.

---

# Phase 14 — Swap Expansion

Initial swap:
2 GB

Need identified because:

* only 2 GB RAM
* Docker planned
* HDD-based system

Swap expansion script created.

Final target:
10 GB swap.

Important concepts learned:

* swap as overflow RAM
* persistence via /etc/fstab
* swap permissions
* memory management

---

# Phase 15 — Docker Installation

Docker installation automated using script.

Installed:

* Docker Engine
* Docker service
* Docker group permissions

Validated using:

docker run hello-world

Important concepts learned:

* images
* containers
* Docker daemon
* Docker Hub
* detached services

---

# Phase 16 — Portainer Planning

Planned first real service:
Portainer.

Reasons:

* lightweight
* visual Docker management
* great for learning
* low RAM usage

Future stack planned:

* Portainer
* Uptime Kuma
* self-hosted GitHub runner
* monitoring stack

---

# Phase 17 — GitHub Self-Hosted Runner Planning

Planned infrastructure:

* self-hosted CI/CD runner
* Docker-capable runner
* workflow_dispatch support

Document/script created for:

* installation
* enable/disable
* systemd service
* logs
* runner management

---

# Major Technical Lessons Learned

## 1. Infrastructure Stability > Features

Stable networking and power behavior matter more than installing advanced tools.

## 2. Ethernet > Wi-Fi for Servers

Servers should ideally avoid Wi-Fi due to:

* roaming
* supplicant issues
* power saving
* instability

## 3. Ubuntu Server > Desktop for Homelabs

Server edition provides:

* lower RAM usage
* fewer background services
* fewer sleep-related issues
* better operational stability

## 4. Real Problems Are Usually Infrastructure Problems

Most failures encountered were:

* networking
 
