{
  description = "Hardware Implementations";

  outputs = { ... }: {
    nixosModules = {
      nixos-nvme = import ./nixos-nvme.nix;
    };
  };
}
