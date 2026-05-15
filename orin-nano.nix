# orin-nano.nix — NVIDIA Jetson Orin Nano hardware module
{ inputs, ... }:

{
  imports = [
    inputs.jetpack-nixos.nixosModules.default
  ];

  # ─── Jetson Orin Nano Configuration ────────────────────────
  # carrier board: p3768 (Orin Nano / Orin NX devkit)
  # som: p3767 (Orin Nano 8GB)
  hardware.nvidia-jetpack = {
    enable = true;
    som = "orin-nano"; # Orin Nano 8GB
    carrierBoard = "devkit"; # Devkit carrier
  };

  # ─── Performance & Optimization ────────────────────────────
  # Orin Nano 8GB is RAM-limited, ZRAM is essential
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50; # 4GB of ZRAM for better LLM headroom
  };

  # Maximize CPU performance
  powerManagement.cpuFreqGovernor = "performance";

  # ─── Storage & Boot ────────────────────────────────────────
  # NVMe is preferred for Orin Nano performance
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Enable the serial console for debugging
    kernelParams = [ "console=ttyTCU0,115200" ];
  };

  # Support for CUDA and hardware acceleration
  nixpkgs.config.allowUnfree = true;
  hardware.nvidia.powerManagement.enable = true;
}
