# NixOS Config for the Homelab

This repo contains the configuration for various VMs running on my Proxmox cluster. Each VM is named after a favorite DJ (list below).

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
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/netalertx.svg' width=32 height=32>|NetAlert X|Self hosted network monitoring|Services|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/syncthing.svg' width=32 height=32>|Syncthing|Open source continuous file synchronization|Services|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/uptime-kuma.svg' width=32 height=32>|Uptime Kuma|Service monitoring tool|Services|

### marcel
|Icon|Name|Description|Category|
|---|---|---|---|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/caddy.svg' width=32 height=32>|Caddy|Web server with automatic HTTPS|Services|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/tailscale.svg' width=32 height=32>|Tailscale|Zero-config VPN mesh network|Networking|

### oscar
|Icon|Name|Description|Category|
|---|---|---|---|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/png/pinchflat.png' width=32 height=32>|Pinchflat|YouTube media manager|Downloads|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/prowlarr.svg' width=32 height=32>|Prowlarr|PVR indexer|Arr|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sabnzbd.svg' width=32 height=32>|SABnzbd|The free and easy binary newsreader|Downloads|


## How it works

> See [Create a NixOS VM on Proxmox](https://www.edwardhorsey.dev/blog/create-a-nixos-vm-on-proxmox/) to get setup.

Clone the repo to your home folder under `~/nix-config`.

### Rebuild

```bash
cd  ~/nix-config

sudo nixos-rebuild switch --flake .#adriana

# or

sudo nixos-rebuild switch --flake .#dasha

# or

sudo nixos-rebuild switch --flake .#marcel

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
```

## Links

 - [Adriana Lopez](https://soundcloud.com/adrianalopez)
 - [Dasha Rush](https://soundcloud.com/dasha-rush)
 - [Marcel Dettmann](https://soundcloud.com/marceldettmann)
 - [Oscar Mulero](https://soundcloud.com/oscarmulero)