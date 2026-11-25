# Nix Hardware

This repository contains reusable NixOS hardware modules.

## Modules

- `nixos-nvme`: Hardware configuration for the primary NVMe-based NixOS workstation.
- `intel-compute`: Hardware configuration for an Intel-based compute host.
- `orin-nano`: Hardware configuration for the Jetson Orin Nano.
- `lxc-guest`: Hardware profile for NixOS running as an LXC guest.
- `rpi5`: Raspberry Pi 5, composed on top of `nixos-hardware`'s upstream module.

## Usage

Import this flake in your `flake.nix` and use the modules in `nixosConfigurations`.

```nix
inputs.nix-hardware.url = "github:kleinbem/nix-hardware";
# ...
modules = [
  inputs.nix-hardware.nixosModules.nixos-nvme
];
```

Swap `nixos-nvme` for any of the module names above.
