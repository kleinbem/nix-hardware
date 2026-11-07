# orin-nano.nix — NVIDIA Jetson Orin Nano hardware module
# Import it through the flake's nixosModules.orin-nano, which adds jetpack-nixos.
{ lib, ... }:

{
  # ─── Jetson Orin Nano Configuration ────────────────────────
  # carrier board: p3768 (Orin Nano / Orin NX devkit)
  # som: p3767 (Orin Nano 8GB)
  hardware.nvidia-jetpack = {
    enable = true;
    som = "orin-nano"; # Orin Nano 8GB
    carrierBoard = "devkit"; # Devkit carrier
  };

  # ─── Performance & Optimization ────────────────────────────
  # 8GB RAM: give Frigate + llama-cpp more compressed headroom than the fleet
  # default (50%, nix-config modules/nixos/core.nix); mkForce overrides it.
  zramSwap = {
    enable = lib.mkForce true;
    algorithm = lib.mkForce "zstd";
    memoryPercent = lib.mkForce 75; # ~6GB ZRAM out of 8GB RAM
  };

  # Maximize CPU performance
  powerManagement.cpuFreqGovernor = "performance";

  # No power profile here: the host sets it via services.nvpmodel. With the
  # Super firmware 0 = 15W (not MAXN), so an `nvpmodel -m 0` here would undo it.

  # ─── Storage & Boot ────────────────────────────────────────
  # NVMe is preferred for Orin Nano performance
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Enable the serial console for debugging
    kernelParams = [ "console=ttyTCU0,115200" ];

    # JetPack's defconfig lacks nftables pieces the NixOS firewall (fib rpfilter,
    # ct state) and nix-gantry's egress table need. Without them container
    # rulesets fail to load and containers run with no firewall at all.
    # tracking: kleinbem/nix-hardware#107 (report to anduril/jetpack-nixos)
    kernelPatches = [
      {
        name = "nftables-fleet";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
          NFT_CT = module;
          NFT_FIB_IPV4 = module;
          NFT_FIB_IPV6 = module;
          NFT_FIB_INET = module;
          NFT_REDIR = module;
          NFT_LIMIT = module;
          NFT_HASH = module;
          NFT_NUMGEN = module;
          NFT_QUOTA = module;
          NFT_OBJREF = module;
          NFT_CONNLIMIT = module;
        };
      }
    ];
  };

  # Support for CUDA and hardware acceleration
  nixpkgs.config.allowUnfree = true;
  hardware.nvidia.powerManagement.enable = true;
}
