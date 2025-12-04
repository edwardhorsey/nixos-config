let
  ned = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2nGjBiNIuotvYq00pwatz8VHo+9P8mE6J68QAu0Y1N ned nixos audiobookshelf";
in
{
  "nas-credentials.age" = {
    publicKeys = [ ned ];
    armor = true;
  };
}