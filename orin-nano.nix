# orin-nano.nix — NVIDIA Jetson Orin Nano hardware module
{ inputs, ... }:

{
  imports = [
    inputs.jetpack-nixos.nixosModules.default
  ];

  # ─── Jetson Orin Nano Configuration ────────────────────────
  # carrier board: p3768 (Orin Nano / Orin NX devkit)
  # som: p3767 (Orin Nano 8GB)
  services.jetpack-nixos = {
    enable = true;
    som = "p3767-0003"; # Orin Nano 8GB
    carrier = "p3768-0000"; # Devkit carrier
  };

  # ─── Storage & Boot ────────────────────────────────────────
  # NVMe is preferred for Orin Nano performance
  boot.loader.generic-extlinux-compatible.enable = true;

  # Support for CUDA and hardware acceleration
  nixpkgs.config.allowUnfree = true;
  hardware.nvidia.powerManagement.enable = true;

  # Enable the serial console for debugging
  boot.kernelParams = [ "console=ttyTCU0,115200" ];
}
