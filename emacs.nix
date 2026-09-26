{
  pkgs ? import <nixpkgs> { },
}:

let
  epkgs = pkgs.emacsPackagesFor pkgs.emacs;

  egpkgs = pkgs.emacsPackagesFor pkgs.emacs-pgtk;

  mkNord =
    e:
    e.trivialBuild {
      pname = "nord";
      version = "0";
      src = ./nord-theme.el;
    };

  mkConfig =
    e:
    e.trivialBuild {
      pname = "config";
      version = "0";
      src = ./default.el;

      packageRequires = [

        # nord theme
        (mkNord e)

        # nix
        e.nix-mode

        # rust
        e.rust-mode

        # go
        e.go-mode

        # terminal emulator
        e.vterm

        # completions
        e.corfu

      ];
    };

  emacs = epkgs.emacsWithPackages (e: [ (mkConfig e) ]);

  emacsg = egpkgs.emacsWithPackages (e: [ (mkConfig e) ]);

  emacsPath = pkgs.lib.makeBinPath [

    # nix
    pkgs.lix
    pkgs.nixd
    pkgs.nixfmt

    # rust
    pkgs.rustc
    pkgs.cargo
    pkgs.rust-analyzer
    pkgs.rustfmt

    # go
    pkgs.go
    pkgs.gopls

    # python
    pkgs.python3
    pkgs.pyright
    pkgs.black

  ];

  emacsWrapped = pkgs.writeShellScript "emacs" ''
    export PATH=$PATH:${emacsPath}

    ${pkgs.lib.getExe' emacs "emacs"} -nw --no-splash "$@"
  '';

  emacsAliases = pkgs.symlinkJoin {
    name = "emacs-aliases";
    paths = [
      (pkgs.writeShellScriptBin "vi" (emacsWrapped.text))
      (pkgs.writeShellScriptBin "e" (emacsWrapped.text))
      (pkgs.writeShellScriptBin "eg" (emacsgWrapped.text))
    ];
  };

  emacsgWrapped = pkgs.writeShellScriptBin "emacsg" ''
    export PATH=$PATH:${emacsPath}

    ${pkgs.lib.getExe' emacsg "emacs"} --no-splash "$@"
  '';

  emacsvWrapped = pkgs.writeShellScriptBin "emacsv" ''
    ${pkgs.lib.getExe' pkgs.emacs "emacs"} "$@"
  '';
in

pkgs.symlinkJoin {
  name = "emacs";
  paths = [
    emacs
    emacsAliases
    emacsgWrapped
    emacsvWrapped
  ];

  postBuild = ''
    rm -f $out/bin/emacs
    ln -s ${emacsWrapped} $out/bin/emacs  
  '';
}
