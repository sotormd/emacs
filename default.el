;; nord theme
(require 'nord-theme)
(load-theme 'nord t)

;; nix
(autoload 'nix-mode "nix-mode" "Major mode for Nix." t)
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode)) 

;; fuzzy find
(fido-vertical-mode 1)

;; hide menu bar
(menu-bar-mode 0)

;; line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1) 

;; highlight current line
(global-hl-line-mode 1)

;; dont leave backup, autosave and lock files
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

;; suppress warnings about lexbind-cookie
(add-to-list 'warning-suppress-log-types
             '(files missing-lexbind-cookie))
