# emacs

[Emacs](https://www.gnu.org/software/emacs/) configuration, provisioned using [Nix](https://nixos.org/download/).

# usage

1.  add this flake as an input

    ```nix
    inputs.emacs.url = "github:sotormd/emacs";
    ```

2.  use the packages provided by this flake

    1.  `packages.x86_64-linux.default`
    2.  `packages.aarch64-linux.default`

or

1. run directly

```bash
nix run github:sotormd/emacs
```

# aliases

| Binary                   | Aliases          |
| ------------------------ | ---------------- |
| Emacs PGTK               | `emacsg` `eg`    |
| Emacs TUI                | `emacs` `e` `vi` |
| Emacs TUI (unconfigured) | `emacsv`         |

# features

- fido fuzzy find
- corfu completions
- vterm terminal emulator
- nord theme
- eglot lsp client
- flymake linting
- formatting

# languages

| Language | LSP             | Formatting |
| -------- | --------------- | ---------- |
| Nix      | `nixd`          | `nixfmt`   |
| Rust     | `rust-analyzer` | `rustfmt`  |
| Go       | `gopls`         | `gofmt`    |
| Python   | `pyright`       | `black`    |
| Markdown | `marksman`      | `prettier` |
