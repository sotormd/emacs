# emacs

[Emacs](https://www.gnu.org/software/emacs/) configuration, provisioned using [Nix](https://nixos.org/download/).

# usage

run directly:

```bash
nix run github:sotormd/emacs
```

or import into another flake:

```nix
inputs.emacs.url = "github:sotormd/emacs";
```

available packages:

- `packages.x86_64-linux.default`
- `packages.aarch64-linux.default`

# aliases

| Binary                   | Aliases          |
| ------------------------ | ---------------- |
| Emacs PGTK               | `emacsg` `eg`    |
| Emacs TTY                | `emacs` `e` `vi` |
| Emacs TTY (unconfigured) | `emacsv`         |

# features

- fido fuzzy find
- corfu completions
- vterm terminal emulator
- nord theme
- eglot lsp client
- flymake linting
- formatting

# languages

| Language | LSP             | Formatter  |
| -------- | --------------- | ---------- |
| Nix      | `nixd`          | `nixfmt`   |
| Rust     | `rust-analyzer` | `rustfmt`  |
| Go       | `gopls`         | `gofmt`    |
| Python   | `pyright`       | `black`    |
| Markdown | `marksman`      | `prettier` |
