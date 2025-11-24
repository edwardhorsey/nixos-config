# NixOS Config for TheNEDLab



## Create secrets file

```bash
EDITOR=vim nix --extra-experimental-features 'nix-command flakes' run github:ryantm/agenix -- -e nas-credentials.age
```

Then enter the credentials file info in vim in terminal, this will create `nas-credentials.age`

Copy to the host machine 

```bash
# replace <host-ip>
 scp ./nas-credentials.age ned@<host-ip>:/home/ned/nas-credentials.age
```

Meh, this only copies it to my user though, so will need to ssh in and move it again to `/etc/nixos/secrets/` folder for use by `nixos-rebuild`