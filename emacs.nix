{
  lib,
  emacsPackagesFor,
  emacs-pgtk,
  lix,
  nixd,
  nixfmt,
  rustc,
  cargo,
  rust-analyzer,
  rustfmt,
  go,
  gopls,
  python3,
  pyright,
  black,
  marksman,
  prettier,
  symlinkJoin,
  writeShellScript,
  writeShellScriptBin,
}:

let
  epkgs = emacsPackagesFor emacs-pgtk;

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

        # completions
        e.corfu

      ];
    };

  emacs = epkgs.emacsWithPackages (e: [ (mkConfig e) ]);

  emacsPath = lib.makeBinPath [

    # nix
    lix
    nixd
    nixfmt

    # rust
    rustc
    cargo
    rust-analyzer
    rustfmt

    # go
    go
    gopls

    # python
    python3
    pyright
    black

    # markdown
    marksman
    prettier

  ];

  common = ''
    export PATH=$PATH:${emacsPath}

    if [ -z "$EMACS_SERVER_NAME" ]; then
      export EMACS_SERVER_NAME="emacs-$(head -c 16 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 12)"
    fi

    export EDITOR="${lib.getExe' emacs "emacsclient"} -s $XDG_RUNTIME_DIR/emacs/$EMACS_SERVER_NAME"

    export server_name="$EMACS_SERVER_NAME"
  '';

  emacsWrapped = writeShellScript "emacs" ''
    ${common}
    ${lib.getExe' emacs "emacs"} --no-splash --eval "(setq server-name \"$server_name\")" --eval "(server-start)" "$@"
  '';

  emacsAliases = symlinkJoin {
    name = "emacs-aliases";
    paths = [
      (writeShellScriptBin "e" (emacsttyWrapped.text))
      (writeShellScriptBin "vi" (emacsttyWrapped.text))
    ];
  };

  emacsttyWrapped = writeShellScriptBin "emacs-tty" ''
    ${common}
    ${lib.getExe' emacs "emacs"} -nw --no-splash --eval "(setq server-name \"$server_name\")" --eval "(server-start)" "$@"
  '';
in

symlinkJoin {

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
