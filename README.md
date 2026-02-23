# NixOS Config

This repo contains the configuration for various machines.

## Devices

### t14

Lenovo Thinkpad T14 Gen 2 i5 11th 16GB. Traveling laptop.

## VMs

Running in a Proxmox cluster, each named after a favorite DJ (see below)

### adriana
|Icon|Name|Description|Category|
|---|---|---|---|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/audiobookshelf.svg' width=32 height=32>|Audiobookshelf|Audiobook and podcast player|Media|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/immich.svg' width=32 height=32>|Immich|Self-hosted photo and video management solution|Media|

### dasha
|Icon|Name|Description|Category|
|---|---|---|---|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/png/baikal.png' width=32 height=32>|Baikal|CalDAV and CardDAV server|Services|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/gitea.svg' width=32 height=32>|Gitea|Self hosted Git service|Services|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/open-webui.svg' width=32 height=32>|Open WebUI|Self hosted AI platform|Services|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/netalertx.svg' width=32 height=32>|NetAlert X|Self hosted network monitoring|Services|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/syncthing.svg' width=32 height=32>|Syncthing|Open source continuous file synchronization|Services|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/uptime-kuma.svg' width=32 height=32>|Uptime Kuma|Service monitoring tool|Services|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/caddy.svg' width=32 height=32>|Caddy|Web server with automatic HTTPS|Services|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/tailscale.svg' width=32 height=32>|Tailscale|Zero-config VPN mesh network|Networking|

### oscar
|Icon|Name|Description|Category|
|---|---|---|---|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/png/pinchflat.png' width=32 height=32>|Pinchflat|YouTube media manager|Downloads|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/prowlarr.svg' width=32 height=32>|Prowlarr|PVR indexer|Arr|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sabnzbd.svg' width=32 height=32>|SABnzbd|The free and easy binary newsreader|Downloads|


## How it works

See [Create a NixOS VM on Proxmox](https://www.edwardhorsey.dev/blog/create-a-nixos-vm-on-proxmox/) post.

Clone the repo to your home folder under `~/nix-config`.

### Rebuild

```bash
cd  ~/nix-config

sudo nixos-rebuild switch --flake .#adriana

# or

sudo nixos-rebuild switch --flake .#dasha

# or

sudo nixos-rebuild switch --flake .#oscar
```

### Create secrets file

Add a new entry in `secrets.nix`.

```bash
EDITOR=vim nix --extra-experimental-features 'nix-command flakes' run github:ryantm/agenix -- -e nas-credentials.age
```

Then enter the credentials information in Vim in the terminal. This will create `nas-credentials.age`.

### Useful commands

```bash
# Update flake
sudo nix --extra-experimental-features 'nix-command flakes' flake update

# Remove old packages and installations
nix-collect-garbage

# Formatter
find . -name '*.nix' -exec nixfmt -- {} +
```

## Links

 - [Adriana Lopez](https://soundcloud.com/adrianalopez)
 - [Dasha Rush](https://soundcloud.com/dasha-rush)
 - [Oscar Mulero](https://soundcloud.com/oscarmulero)