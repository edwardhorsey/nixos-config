# Agent Instructions

## Scope

This repository is a personal NixOS flake for home infrastructure. Treat changes as production infrastructure changes: prefer small, reviewable edits and do not apply a configuration to a live host without explicit approval.

These instructions apply to the whole repository. If a more specific `AGENTS.md` is added later, its instructions apply to files below that directory as well.

## Repository Layout

- `flake.nix`: flake inputs, the formatter, and the `nixosConfigurations` outputs.
- `flake.lock`: pinned revisions for all flake inputs. Keep it committed and update it deliberately.
- `modules/`: shared NixOS modules used by multiple hosts.
- `machines/<host>/`: host entry point and generated hardware configuration.
- `machines/*/local.nix`: private, machine-local configuration. These files are intentionally ignored by Git and may be required to evaluate a host.
- `secrets.nix`: agenix recipient metadata. It contains public keys, not secret values.
- `secrets/*.age`: encrypted agenix secrets. Never decrypt or expose their contents in logs, patches, or the Nix store.
- `README.md`: user-facing host inventory and operational notes.

## Current Hosts

All hosts target `x86_64-linux`.

- `adriana`: Audiobookshelf and Immich; uses a private `local.nix` and agenix.
- `dasha`: Syncthing, Uptime Kuma, Beszel, Baikal, FreshRSS, Gitea, and SearXNG; uses a private `local.nix` and agenix.
- `donato`: Caddy and Tailscale; no ignored `local.nix` import.
- `oscar`: media and download services, NAS mounts, and WireGuard; uses a private `local.nix` and agenix. It follows `nixpkgs-unstable`.
- `t14`: desktop/laptop configuration with Cosmic, desktop applications, Tailscale, and Syncthing.

## Nix Conventions

- Use the existing module structure. Put settings shared by hosts in `modules/`; keep hardware, hostname, mounts, services, and host-specific firewall rules in the relevant machine module.
- Preserve the distinction between stable `nixpkgs` and `nixpkgsUnstable`. Do not move a host between channels as part of an unrelated change.
- Use NixOS module options and package attributes from the pinned inputs rather than inventing option or package names. Check option and package availability before editing.
- Keep `system.stateVersion` unchanged unless an intentional migration is being performed. It is not an automatic upgrade switch.
- Do not edit `hardware-configuration.nix` casually. These files are generated from the target hardware; change them only for a deliberate hardware or filesystem migration.
- Follow the formatting already used in the repository: two-space indentation, trailing commas where the surrounding expression uses them, and `nixfmt` formatting.
- Avoid adding new flake inputs for one-off commands. Prefer `nix run` or an existing input when practical.
- Do not update `flake.lock` incidentally. A lock-file change must explain which input changed and why.

## Secrets and Safety

- Never put plaintext credentials, tokens, private keys, passwords, or private host details in tracked files.
- Do not read an `.age` file into Nix with `builtins.readFile` or interpolate decrypted content into a derivation. Reference runtime paths such as `config.age.secrets.<name>.path` instead.
- Do not create, edit, decrypt, rekey, rotate, or otherwise manage agenix secrets. The user creates and maintains encrypted secrets with agenix on one of their machines.
- When a secret is added or renamed, the agent may update the corresponding tracked metadata and host declaration, but must leave secret creation and rekeying to the user.
- Keep agenix identity paths as runtime string paths. Do not use a Nix path for an SSH private key, because it can copy the key into the Nix store.
- Treat changes to SSH access, firewall rules, mounts, VPN routing, boot loaders, and service bind addresses as high risk. Explain operational impact before applying them.
- Do not deploy or apply configurations to any host. The user performs all deployments.
- Do not attempt host builds for verification or any other reason unless the user explicitly requests one. All host builds and deployments are performed by the user by default.
- Do not run `nixos-rebuild switch`, reboot, delete generations, or garbage-collect on a host, even while validating a change.
- Except for formatting changed files as described below, do not run commands that evaluate a host configuration, build or realize derivations, enter development shells, run packages through Nix, update lock files, deploy configurations, contact remote hosts, or mutate running system or container state unless the user explicitly requests that exact action. This includes `nix build`, `nix flake check`, host-oriented `nix eval`, `nix run`, `nix shell`, `nix develop`, all `nixos-rebuild` modes, and remote or service-management commands. Providing a command for the user to run is not permission to execute it.
- Read-only Nix commands may be used to research packages, versions, metadata, option definitions, and existing store paths. This includes `nix search`, package-scoped `nix eval`, `nix path-info`, and `nix-store --query`. Do not use this exception to evaluate a host configuration or realize a derivation.

## Verification Workflow

Run commands from the repository root.

The machine editing this repository may or may not have Nix installed or a `/nix/store`. Check the available tooling before running Nix commands. If Nix is unavailable, do not assume store paths exist; perform repository-level checks that are available and report the Nix formatting, evaluation, or build commands that still need to be run on a Nix-capable machine.

1. Inspect the relevant host and shared modules before editing.
2. Format changed Nix files by passing their paths explicitly:

   ```bash
   nix fmt path/to/changed-file.nix path/to/another-changed-file.nix
   ```

   Do not invoke bare `nix fmt` in this repository. With the pinned `nixfmt` version, the flake formatter receives empty standard input and fails with `unexpected end of input`; explicit file paths avoid this issue.
3. Evaluate the flake only when the user explicitly requests it:

   ```bash
   nix flake check
   ```

4. Do not build a host unless the user explicitly asks for a host build. If evaluation requires an ignored `local.nix` that is unavailable, report that limitation rather than creating a guessed file or attempting a substitute host build.
5. Review `git diff` and `git status`. Confirm that only intended files changed and that no plaintext secret or `result` link is included.

Deployment commands are documented for the user's reference only. Agents must not run `nixos-rebuild switch`, `--target-host`, or other deployment commands. This repository does not define a deployment tool or a CI pipeline.

## MCP-NixOS (Optional)

`mcp-nixos` is a community MCP server from [utensils/mcp-nixos](https://github.com/utensils/mcp-nixos), not an official NixOS component. It can query current package and option indexes, Home Manager and nix-darwin options, flake metadata, `nix.dev`, and other Nix resources. It is useful for checking whether a package or option exists before writing configuration, but its answers do not replace evaluation against this flake's pinned inputs.

If the MCP client supports project instructions, use the server as a read-only research aid. A client configuration can be added outside this repository, for example:

```json
{
  "mcpServers": {
    "nixos": {
      "command": "nix",
      "args": ["run", "github:utensils/mcp-nixos", "--"]
    }
  }
}
```

The server can also be run with `uvx mcp-nixos`. Prefer a pinned or otherwise reviewed version for repeatable work, and do not grant it access to private files or secrets. MCP configuration is client-specific, so this repository intentionally does not add `.mcp.json`; configure it in the editor or assistant that will use it.

When using it, query the relevant NixOS channel and then verify locally. For this repository, local evaluation and `flake.lock` take precedence over a remote index.

## Reference Documentation

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix reference manual: flakes](https://nix.dev/manual/nix/2.28/command-ref/new-cli/nix3-flake)
- [NixOS options search](https://search.nixos.org/options)
- [NixOS packages search](https://search.nixos.org/packages)
- [NixOS Wiki](https://wiki.nixos.org/)
- [agenix](https://github.com/ryantm/agenix)
- [MCP-NixOS](https://mcp-nixos.io/)
- [MCP local server guidance](https://modelcontextprotocol.io/docs/develop/connect-local-servers)
