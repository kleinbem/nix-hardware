# nix-hardware Justfile
#
# Device-specific hardware modules (nixos-nvme, orin-nano, rpi5, lxc-guest, …).

[group("Main")]
default:
    @just --list

[group("Linter")]
check:
    @echo "🔧 Verifying hardware modules flake..."
    @nix flake check . --impure

[group("Linter")]
fmt:
    @nix fmt

# List every hardware module the flake exposes.
[group("Discovery")]
list-modules:
    @echo "🖥️ Available hardware modules:"
    @nix eval .#nixosModules --apply 'builtins.attrNames' --json 2>/dev/null \
        | jq -r '.[]' 2>/dev/null \
        || nix flake show .
