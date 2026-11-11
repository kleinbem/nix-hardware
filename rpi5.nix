# rpi5.nix — Raspberry Pi 5 hardware profile
{ nixos-hardware }:
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Boot — RPi uses U-Boot or direct kernel with extlinux
  boot = {
    # Upstream's kernel.nix drops boot.kernelPatches (upstream: NixOS/nixos-hardware#1745),
    # so they go in through argsOverride, which replaces its list: keep the rest in sync.
    # Priority 999 beats upstream's mkDefault; a host's own kernel still wins.
    kernelPackages = lib.mkOverride 999 (
      pkgs.linuxPackagesFor (
        pkgs.callPackage "${nixos-hardware}/raspberry-pi/common/kernel.nix" {
          rpiVersion = 5;
          argsOverride.kernelPatches =
            with pkgs.kernelPatches;
            [
              bridge_stp_helper
              request_key_helper
            ]
            ++ lib.optional (pkgs.kernelPatches ? tools_128bit_types) tools_128bit_types
            ++ config.boot.kernelPatches;
        }
      )
    );

    # Console on serial (useful for headless debugging)
    kernelParams = [
      "console=ttyAMA0,115200"
      "console=tty1"
    ];
  };

  # File system defaults (SD card or NVMe)
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  # Swap — RPi has limited RAM, zram helps
  zramSwap = {
    enable = lib.mkDefault true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
}
