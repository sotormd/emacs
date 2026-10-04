{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ./emacs.nix { }
