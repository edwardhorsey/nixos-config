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
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/syncthing.svg' width=32 height=32>|Syncthing|Open Source Continuous File Synchronization|Services|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/uptime-kuma.svg' width=32 height=32>|Uptime Kuma|Service monitoring tool|Services|

### oscar
|Icon|Name|Description|Category|
|---|---|---|---|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/png/pinchflat.png' width=32 height=32>|Pinchflat|YouTube media manager|Downloads|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/prowlarr.svg' width=32 height=32>|Prowlarr|PVR indexer|Arr|
|<img src='https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sabnzbd.svg' width=32 height=32>|SABnzbd|The free and easy binary newsreader|Downloads|


## How it works

First, clone the repo to your home folder under `~/nix-config`.

## Rebuild

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

## Create secrets file

Add a new entry in `secrets.nix`.

```bash
EDITOR=vim nix --extra-experimental-features 'nix-command flakes' run github:ryantm/agenix -- -e nas-credentials.age
```

Then enter the credentials information in Vim in the terminal. This will create `nas-credentials.age`.

Copy to the host machine:

```bash
# replace <host-ip>
scp ./nas-credentials.age ned@<host-ip>:/home/ned/nas-credentials.age
```

Then move it to `~/nix-config/secrets`.

## Links

 - [Adriana Lopez](https://soundcloud.com/adrianalopez)
 - [Dasha Rush](https://soundcloud.com/dasha-rush)
 - [Oscar Mulero](https://soundcloud.com/oscarmulero)