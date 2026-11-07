# lxc-guest.nix — Hardware profile for NixOS running as an LXC guest.
# No bootloader, no kernel (shared with host), minimal hardware config.
{ lib, ... }:

{
  # LXC guests share the host kernel — don't build one
  boot = {
    isContainer = true;

    # No bootloader needed
    loader.grub.enable = false;

    # No initrd in containers
    initrd.enable = false;
  };

  # Minimal filesystem (host provides the root)
  fileSystems."/" = lib.mkDefault {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=2G"
      "mode=755"
    ];
  };

  # Networking: let the LXC host manage
  networking.useDHCP = lib.mkDefault true;
}
