let
  adriana = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2nGjBiNIuotvYq00pwatz8VHo+9P8mE6J68QAu0Y1N";
  oscar = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBwcElnf3G0KA6mLuhPg2iyUWLKv5UT+xEgDy6b9aRdH";
in
{
  "adriana-media-credentials.age" = {
    publicKeys = [ adriana ];
    armor = true;
  };
  "adriana-photos-credentials.age" = {
    publicKeys = [ adriana ];
    armor = true;
  };
  "oscar-media-credentials.age" = {
    publicKeys = [ oscar ];
    armor = true;
  };
}
