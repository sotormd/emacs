{
  description = "emacs configuration";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs =
    inputs:
    let
      pkgs-x86_64 = inputs.nixpkgs.legacyPackages.x86_64-linux;
      pkgs-aarch64 = inputs.nixpkgs.legacyPackages.aarch64-linux;
    in
    {
      packages.x86_64-linux.default = pkgs-x86_64.callPackage ./emacs.nix { };
      packages.aarch64-linux.default = pkgs-aarch64.callPackage ./emacs.nix { };
    };
}
