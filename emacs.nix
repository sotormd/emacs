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
      emacsPackages.nord-theme
      emacsPackages.nix-mode
    ];
  };

  emacs = emacsPackages.emacsWithPackages (_: [
    config
  ]);

  emacsPath = pkgs.lib.makeBinPath [
    pkgs.nixd
    pkgs.nixfmt
    pkgs.rust-analyzer
    pkgs.gopls
    pkgs.haskell-language-server
    pkgs.pyright
    pkgs.ruff
  ];

  emacsWrapped = pkgs.writeShellScript "emacs" ''
    export PATH=$PATH:${emacsPath}

    ${pkgs.lib.getExe' emacs "emacs"} --no-splash "$@"
  '';

  emacsVanilla = pkgs.writeShellScript "emacsv" ''
    ${pkgs.lib.getExe' pkgs.emacs "emacs"}
  '';
in

pkgs.symlinkJoin {
  name = "emacs";

  paths = [
    emacs
  ];

  postBuild = ''
    rm -f $out/bin/emacs
    ln -s ${emacsWrapped} $out/bin/emacs  
    ln -s ${emacsVanilla} $out/bin/emacsv
  '';
}
