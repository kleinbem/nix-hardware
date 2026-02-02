# Nix Hardware

This repository contains reusable NixOS hardware modules.

## Modules

- `nixos-nvme`: Hardware configuration for the primary NVMe-based NixOS workstation.

## Usage

Import this flake in your `flake.nix` and use the modules in `nixosConfigurations`.

```nix
inputs.nix-hardware.url = "github:kleinbem/nix-hardware";
# ...
modules = [
  inputs.nix-hardware.nixosModules.nixos-nvme
];
```
