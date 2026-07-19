let
  adriana = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2nGjBiNIuotvYq00pwatz8VHo+9P8mE6J68QAu0Y1N";
  dasha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJRrL1fhZiT9Ad2yBCmEY7ffmJa7froZY4ZRsFtuoMYk";
  oscar = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBwcElnf3G0KA6mLuhPg2iyUWLKv5UT+xEgDy6b9aRdH";
in
{
  "adriana-media-credentials.age" = {
    publicKeys = [ adriana ];
    armor = true;
  };
  "dasha-searxng-secret.age" = {
    publicKeys = [ dasha ];
    armor = true;
  };
  "oscar-sabnzbd-config.age" = {
    publicKeys = [ oscar ];
    armor = true;
  };
  "slskd-config.age" = {
    publicKeys = [ oscar ];
    armor = true;
  };
  "oscar-wireguard-config.age" = {
    publicKeys = [ oscar ];
    armor = true;
  };
}
