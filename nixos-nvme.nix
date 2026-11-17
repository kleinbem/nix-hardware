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

    # kvm-intel / kvm-amd load on their own from the CPU's vmx / svm flag.
    extraModulePackages = [ ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
