;; nord theme
(require 'nord-theme)
(load-theme 'nord t)

;; languages

;; nix
(require 'nix-mode)

;; suppress warnings about lexical-cookie
(add-to-list 'warning-suppress-log-types '(files missing-lexbind-cookie))
