# nixos-nvme.nix — kernel modules and platform of the nixos-nvme workstation.
# Disks, LUKS and swap live in the host's disko config in nix-config.
{
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "ahci"
        "nvme"
        "usbhid"
        "ums_realtek"
        "uas"
        "sd_mod"
      ];
      kernelModules = [ "dm-snapshot" ];

      services.lvm.enable = true;
    };

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
