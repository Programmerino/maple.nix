# maple.nix

To use on your system, do something similar to the following when importing:
```nix
inputs.maple-installer = {
    url = "/home/davis/Maple2022.1LinuxX64Installer.run";
    flake = false;
};

# https://wiki.archlinux.org/title/Maple Offline Activation
inputs.license-dat = {
    url = "/home/davis/license.dat";
    flake = false;
};

inputs.maple = {
    url = "github:Programmerino/maple.nix";
    inputs.maple-installer.follows = "maple-installer";
    inputs.license-dat.follows = "license-dat";
};
```