# orin-nano.nix — NVIDIA Jetson Orin Nano hardware module
{ inputs, lib, ... }:

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
  # Orin Nano 8GB is RAM-limited, ZRAM is essential. Bumped from 50% → 75%
  # to give AI workloads (Frigate + llama-cpp) more compressed spillover head-
  # room. base.nix sets 50% as the fleet default; mkForce overrides it here.
  zramSwap = {
    enable = lib.mkForce true;
    algorithm = lib.mkForce "zstd";
    memoryPercent = lib.mkForce 75; # ~6GB ZRAM out of 8GB RAM
  };

  # Maximize CPU performance
  powerManagement.cpuFreqGovernor = "performance";

  # The power profile is the host's choice: nix-config sets it with
  # jetpack-nixos' services.nvpmodel (profile 2 = MAXN_SUPER). With the Super
  # firmware the profiles are 0 = 15W, 1 = 25W, 2 = MAXN_SUPER, so a boot unit
  # that ran `nvpmodel -m 0` here (from the pre-Super numbering, where 0 was
  # MAXN) put the board back to 15W right after that service had applied
  # profile 2.

  # ─── Storage & Boot ────────────────────────────────────────
  # NVMe is preferred for Orin Nano performance
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Enable the serial console for debugging
    kernelParams = [ "console=ttyTCU0,115200" ];

    # NVIDIA's JetPack defconfig leaves out nftables pieces the fleet relies
    # on: the NixOS nftables firewall (fib reverse-path check, ct state) and
    # nix-gantry's zero-trust egress table (ct state). Without them every
    # container's ruleset fails to load here, so Frigate, llama-cpp and
    # syncthing ran with no firewall and no egress restriction.
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
