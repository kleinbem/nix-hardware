# rpi5.nix — Raspberry Pi 5 hardware profile
{ nixos-hardware }:
{ lib, pkgs, ... }:

{
  # Boot — RPi uses U-Boot or direct kernel with extlinux
  boot = {
    # The 6.18 vendor kernel's tools/ lack __u128, which Linux 7.3 headers use
    # on arm64, so the kernel build fails. The upstream kernel.nix sets its own
    # kernelPatches and drops boot.kernelPatches, so argsOverride is the only
    # way in; it replaces upstream's list, keep it in sync. Drop this once
    # upstream applies the patch (upstream: NixOS/nixos-hardware#2106).
    kernelPackages = pkgs.linuxPackagesFor (
      pkgs.callPackage "${nixos-hardware}/raspberry-pi/common/kernel.nix" {
        rpiVersion = 5;
        argsOverride.kernelPatches =
          with pkgs.kernelPatches;
          [
            bridge_stp_helper
            request_key_helper
          ]
          ++ lib.optional (pkgs.kernelPatches ? tools_128bit_types) tools_128bit_types;
      }
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
