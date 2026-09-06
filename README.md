# NixOS Homelab Configuration

Declarative NixOS configuration for a small Proxmox homelab and a Lenovo
ThinkPad T14. The infrastructure runs self-hosted media, file
synchronization, monitoring, search, Git hosting, VPN, and storage-related
services.

This is a personal configuration, not a drop-in NixOS template. Hostnames,
hardware, storage paths, network addresses, domains, and private
configuration are specific to this infrastructure.

## Hosts

The VM hosts run in a Proxmox cluster. They are all named DJs.

| Host | Role | Nixpkgs channel |
| --- | --- | --- |
| `adriana` | Audiobookshelf and Immich | Stable |
| `dasha` | Syncthing, Uptime Kuma, Beszel, Baikal, Gitea, and SearXNG | Stable |
| `donato` | Caddy and Tailscale | Stable |
| `oscar` | Media and download services, NAS mounts, and WireGuard | Unstable |
| `t14` | Desktop/laptop configuration with Cosmic, applications, Tailscale, and Syncthing | Stable |

### Service Inventory

#### `adriana`

| Icon | Name | Description | Category |
| --- | --- | --- | --- |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/audiobookshelf.svg" width="32" height="32" alt="Audiobookshelf"> | Audiobookshelf | Audiobook and podcast player | Media |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/immich.svg" width="32" height="32" alt="Immich"> | Immich | Self-hosted photo and video management | Media |

#### `dasha`

| Icon | Name | Description | Category |
| --- | --- | --- | --- |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/baikal.svg" width="32" height="32" alt="Baikal"> | Baikal | CalDAV and CardDAV server | Services |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/beszel.svg" width="32" height="32" alt="Beszel"> | Beszel | Lightweight server monitoring | Services |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/gitea.svg" width="32" height="32" alt="Gitea"> | Gitea | Self-hosted Git service | Services |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/searxng.svg" width="32" height="32" alt="SearXNG"> | SearXNG | Privacy-respecting metasearch engine | Services |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/syncthing.svg" width="32" height="32" alt="Syncthing"> | Syncthing | Continuous file synchronization | Services |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/uptime-kuma.svg" width="32" height="32" alt="Uptime Kuma"> | Uptime Kuma | Service monitoring tool | Services |

#### `donato`

| Icon | Name | Description | Category |
| --- | --- | --- | --- |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/caddy.svg" width="32" height="32" alt="Caddy"> | Caddy | Web server with automatic HTTPS | Services |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/tailscale.svg" width="32" height="32" alt="Tailscale"> | Tailscale | Zero-configuration VPN mesh network | Networking |

#### `oscar`

| Icon | Name | Description | Category |
| --- | --- | --- | --- |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/beets.svg" width="32" height="32" alt="Beets"> | Beets | Music library manager and tagger | Media |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/pinchflat.png" width="32" height="32" alt="Pinchflat"> | Pinchflat | YouTube media manager | Downloads |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/prowlarr.svg" width="32" height="32" alt="Prowlarr"> | Prowlarr | Indexer manager | Arr |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sabnzbd.svg" width="32" height="32" alt="SABnzbd"> | SABnzbd | Binary newsreader | Downloads |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/slskd.svg" width="32" height="32" alt="slskd"> | slskd | Client-server Soulseek application | Downloads |

## How It Works

The `local.nix` files contain machine-specific values (such as IP addresses) and are intentionally ignored by Git. Copy the relevant `local-example.nix` as a starting point, then supply your own values locally. Do not commit private configuration.

The setup process for the VM hosts is documented in
[Create a NixOS VM on Proxmox](https://www.edwardhorsey.net/blog/create-a-nixos-vm-on-proxmox/).

## Rebuild

Clone the repository on the target NixOS machine:

```bash
git clone https://github.com/edwardhorsey/nixos-config.git ~/nix-config
cd ~/nix-config
```

Build and activate a host configuration:

```bash
sudo nixos-rebuild switch --flake path:.#adriana
sudo nixos-rebuild switch --flake path:.#dasha
sudo nixos-rebuild switch --flake .#donato
sudo nixos-rebuild switch --flake path:.#oscar
sudo nixos-rebuild switch --flake .#t14
```

## Secrets

Secrets are encrypted with [agenix](https://github.com/ryantm/agenix). The
tracked `secrets.nix` file contains recipient metadata, while encrypted
`.age` files contain the secret data.

To create or edit an encrypted secret, add its recipient entry to
`secrets.nix` and run agenix locally:

```bash
EDITOR=vim nix run github:ryantm/agenix -- -e <secret-name>.age
```
Secret creation, rekeying, and identity management are intentionally manual operations.

## Useful Commands

Check and format the flake:

```bash
nix flake check
nix fmt
```

Update flake inputs deliberately:

```bash
nix flake update
```

Remove unused store paths when appropriate:

```bash
nix-collect-garbage
```

## Music

- [Adriana Lopez](https://soundcloud.com/adrianalopez)
- [Dasha Rush](https://soundcloud.com/dasha-rush)
- [Donato Dozzy](https://soundcloud.com/donato-dozzy)
- [Oscar Mulero](https://soundcloud.com/oscarmulero)
