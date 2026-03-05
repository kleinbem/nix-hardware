# rpi5.nix — Raspberry Pi 5 hardware profile
{ pkgs, lib, ... }:

{
  # Kernel — use the latest stable aarch64 kernel
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # RPi 5 firmware & device tree
  hardware.enableRedistributableFirmware = true;

  # GPU (VideoCore VII via Mesa V3D)
  hardware.graphics.enable = lib.mkDefault true;

  # Boot — RPi uses U-Boot or direct kernel with extlinux
  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = lib.mkDefault true;
  };

  # Console on serial (useful for headless debugging)
  boot.kernelParams = [
    "console=ttyAMA0,115200"
    "console=tty1"
  ];

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
