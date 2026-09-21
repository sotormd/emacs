{
  pkgs ? import <nixpkgs> { },
}:

let
  emacsPackages = pkgs.emacsPackagesFor pkgs.emacs;

  config = emacsPackages.trivialBuild {
    pname = "emacs-config";
    version = "0";
    src = ./default.el;
    packageRequires = [
      emacsPackages.nix-mode
      emacsPackages.nord-theme
    ];
  };
in

emacsPackages.emacsWithPackages (_: [ config ])
