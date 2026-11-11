# rpi5.nix — Raspberry Pi 5 hardware profile
nixos-hardware:
{ lib, pkgs, ... }:

let
  # Linux 7.3 UAPI headers (glibc's) use __u128, which the 6.18 vendor tree's
  # tools/include lacks. upstream: NixOS/nixos-hardware#2106. The rpi kernel
  # drops boot.kernelPatches (NixOS/nixos-hardware#1745), so the patch goes in
  # via argsOverride, and only until nixos-hardware carries it itself.
  u128Patch = pkgs.kernelPatches.tools_128bit_types or null;
  rpiKernel = pkgs.callPackage "${nixos-hardware}/raspberry-pi/common/kernel.nix";
  upstreamPatches = (rpiKernel { rpiVersion = 5; }).kernelPatches;
  needsU128Patch = u128Patch != null && !lib.any (p: p.name == u128Patch.name) upstreamPatches;
in
{
  # Boot — RPi uses U-Boot or direct kernel with extlinux
  boot = {

    # Console on serial (useful for headless debugging)
    kernelParams = [
      "console=ttyAMA0,115200"
      "console=tty1"
    ];

    # Above nixos-hardware's mkDefault, below a host's own choice.
    kernelPackages = lib.mkIf needsU128Patch (
      lib.mkOverride 999 (
        pkgs.linuxPackagesFor (rpiKernel {
          rpiVersion = 5;
          argsOverride.kernelPatches = upstreamPatches ++ [ u128Patch ];
        })
      )
    );
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
