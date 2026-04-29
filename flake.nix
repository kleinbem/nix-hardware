{
  description = "Hardware Implementations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    nix-devshells.url = "github:kleinbem/nix-devshells";
    nix-devshells.inputs.nixpkgs.follows = "nixpkgs";

    jetpack-nixos.url = "github:anduril/jetpack-nixos";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      imports = [ ];

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          formatter = inputs.nix-devshells.formatter.${system};

          # Pre-commit checks
          checks.pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt.enable = true;
              statix.enable = true;
              deadnix.enable = true;
            };
          };

          # DevShell
          devShells.default = pkgs.mkShell {
            shellHook = ''
              ${config.checks.pre-commit-check.shellHook}
              echo "🔧 Hardware Flake DevEnv"
            '';
            buildInputs = [
              pkgs.nixfmt
              pkgs.statix
              pkgs.deadnix
            ];
          };
        };

      flake = {
        nixosModules = {
          nixos-nvme = import ./nixos-nvme.nix;
          intel-compute = import ./intel-compute.nix;
          rpi5 = import ./rpi5.nix;
          orin-nano = import ./orin-nano.nix;
          lxc-guest = import ./lxc-guest.nix;
        };
      };
    };
}
# Bump
