{
  description = "Hardware Implementations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { config, pkgs, system, ... }: {
        # Formatting
        treefmt = {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        };

        # Pre-commit checks
        checks.pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt.enable = true;
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
          ];
        };
      };

      flake = {
        nixosModules = {
          nixos-nvme = import ./nixos-nvme.nix;
          intel-compute = import ./intel-compute.nix;
        };
      };
    };
}
