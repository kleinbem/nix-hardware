# nix-hardware

Reusable NixOS hardware modules, one per board/platform.

## Modules (`flake.nix` `nixosModules`)

| Module | File | Board/platform |
|---|---|---|
| `nixos-nvme` | `nixos-nvme.nix` | Primary NVMe-based NixOS workstation |
| `intel-compute` | `intel-compute.nix` | Intel-based compute host |
| `orin-nano` | `orin-nano.nix` | Jetson Orin Nano |
| `lxc-guest` | `lxc-guest.nix` | LXC guest hardware profile |
| `rpi5` | (composed in `flake.nix`) | Raspberry Pi 5, wraps `nixos-hardware`'s upstream module |

## Conventions

- One file per board; import the matching `nixosModules.<name>` from a
  host's `flake.nix`/module list rather than duplicating hardware config
  in `nix-config`.
- Consumed with `inputs.nixpkgs.follows` (and `nix-devshells.follows`
  where relevant) — keep those follows in sync with the consuming flake.
