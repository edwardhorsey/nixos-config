let
  ned = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOpzKI/QwhZSwwJT2ypQaj1KTZbjysufKusojfT0zLCr ned nixos audiobookshelf";
in
{
  "nas-credentials.age" = {
    publicKeys = [ ned ];
    armor = true;
  };
}