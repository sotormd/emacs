{
  pkgs ? import <nixpkgs> { },
}:

let
  epkgs = pkgs.emacsPackagesFor pkgs.emacs-pgtk;

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

        # markdown
        e.markdown-mode

        # terminal emulator
        e.vterm

        # completions
        e.corfu

      ];
    };

  emacs = epkgs.emacsWithPackages (e: [ (mkConfig e) ]);

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

    # markdown
    pkgs.marksman
    pkgs.prettier

  ];

  common = ''
    export PATH=$PATH:${emacsPath}

    if [ -z "$EMACS_SERVER_NAME" ]; then
      export EMACS_SERVER_NAME="emacs-$(head -c 16 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 12)"
    fi

    export EDITOR="${pkgs.lib.getExe' emacs "emacsclient"} -s $XDG_RUNTIME_DIR/emacs/$EMACS_SERVER_NAME"

    export server_name="$EMACS_SERVER_NAME"
  '';

  emacsWrapped = pkgs.writeShellScript "emacs" ''
    ${common}
    ${pkgs.lib.getExe' emacs "emacs"} --no-splash --eval "(setq server-name \"$server_name\")" --eval "(server-start)" "$@"
  '';

  emacsAliases = pkgs.symlinkJoin {
    name = "emacs-aliases";
    paths = [
      (pkgs.writeShellScriptBin "e" (emacsttyWrapped.text))
      (pkgs.writeShellScriptBin "vi" (emacsttyWrapped.text))
    ];
  };

  emacsttyWrapped = pkgs.writeShellScriptBin "emacs-tty" ''
    ${common}
    ${pkgs.lib.getExe' emacs "emacs"} -nw --no-splash --eval "(setq server-name \"$server_name\")" --eval "(server-start)" "$@"
  '';
in

pkgs.symlinkJoin {

  # we need pname and version for bundling
  pname = "emacs";
  version = "0";
  meta.mainProgram = "emacs";

  # real symlinkJoin name
  name = "emacs";

  # paths to join
  paths = [

    # emacs pgtk
    emacs

    # various aliases
    emacsAliases

    # emacs pgtk with -nw
    emacsttyWrapped

  ];

  # replace emacs binary with our wrapper
  postBuild = ''
    rm -f $out/bin/emacs
    ln -s ${emacsWrapped} $out/bin/emacs  
  '';

}
