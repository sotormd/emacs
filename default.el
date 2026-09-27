;;; emacs --- emacs configuration

;;; Commentary:
;;; editor macros

;;; Code:

;; hide menu bar
(menu-bar-mode 0)

;; hide tool bar
(tool-bar-mode 0)

;; hide scroll back
(scroll-bar-mode 0)

;; line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; column numbers
(column-number-mode 1)

;; highlight current line
(global-hl-line-mode 1)
(add-hook 'vterm-mode-hook (lambda () (global-hl-line-mode -1)))

;; nord theme
(require 'nord-theme)
(load-theme 'nord t)

;; font
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-11"))
(dolist (face (face-list)) (set-face-attribute face nil :family "JetBrains Mono" :height 110))

;; fuzzy find
(fido-vertical-mode 1)

;; competions
(require 'corfu)
(global-corfu-mode 1)
(setq corfu-auto t
      corfu-auto-delay 0.3
      corfu-auto-prefix 1)

;; vterm
(autoload 'vterm "vterm" nil t)

;; trust content
;; so that we can use flymake
(setq trusted-content :all)

;; dont leave backup, autosave and lock files
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

;; suppress warnings about lexbind-cookie
(add-to-list 'warning-suppress-log-types '(files missing-lexbind-cookie))

;; call process on a buffer
(defun call-process-on-buffer (command &rest args)
  (let ((pos (point))
	(output (generate-new-buffer "*call-process-on-buffer-temporary-output*")))
    (unwind-protect
	(let ((status (apply #'call-process-region
			     (point-min) (point-max)
			     command nil output nil args)))
	  (if (= status 0)
	      (progn
		(delete-region (point-min) (point-max))
		(insert-buffer-substring output)
		(goto-char pos))
	    (error "%s failed" command)))
      (kill-buffer output))))

;; languages

;; nix - mode
(autoload 'nix-mode "nix-mode" "Major mode for Nix." t)
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))
;; nix - nixd lsp
(add-hook 'nix-mode-hook #'eglot-ensure)
(with-eval-after-load 'eglot (add-to-list 'eglot-server-programs '(nix-mode . ("nixd"))))
;; nix - nixfmt formatter
(defun nixfmt-format-buffer () (interactive) (call-process-on-buffer "nixfmt" "-"))
(add-hook 'nix-mode-hook (lambda () (add-hook 'before-save-hook #'nixfmt-format-buffer nil t)))

;; rust - mode
(autoload 'rust-mode "rust-mode" "Major mode for Rust." t)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
;; rust - rust-analyzer lsp
(add-hook 'rust-mode-hook #'eglot-ensure)
(with-eval-after-load 'eglot (add-to-list 'eglot-server-programs '(rust-mode . ("rust-analyzer"))))
;; rust - rustfmt formatter
(defun rustfmt-format-buffer () (interactive) (call-process-on-buffer "rustfmt" "--emit" "stdout"))
(add-hook 'rust-mode-hook (lambda () (add-hook 'before-save-hook #'rustfmt-format-buffer nil t)))

;; go - go mode
(autoload 'go-mode "go-mode" "Major mode for Go." t)
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))
;; go - gopls lsp
(add-hook 'go-mode-hook #'eglot-ensure)
(with-eval-after-load 'eglot (add-to-list 'eglot-server-programs '(go-mode . ("gopls"))))
;; go - gofmt formatter
(defun gofmt-format-buffer () (interactive) (call-process-on-buffer "gofmt"))
(add-hook 'go-mode-hook (lambda () (add-hook 'before-save-hook #'gofmt-format-buffer nil t)))

;; python - pyright lsp
(add-hook 'python-mode-hook #'eglot-ensure)
(with-eval-after-load 'eglot (add-to-list 'eglot-server-programs '(python-mode . ("pyright-langserver" "--stdio"))))
;; python - black formatter
(defun black-format-buffer () (call-process-on-buffer "black" "-q" "--stdin-filename" buffer-file-name "-"))
(add-hook 'python-mode-hook (lambda () (add-hook 'before-save-hook #'black-format-buffer nil t)))

;; markdown - mode
(autoload 'markdown-mode "markdown-mode" "Major mode for Markdown." t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
;; markdown - marksman lsp
(add-hook 'markdown-mode-hook #'eglot-ensure)
(with-eval-after-load 'eglot (add-to-list 'eglot-server-programs '(rust-mode . ("marksman"))))
;; markdown - prettier formatter
(defun prettier-format-buffer () (interactive) (call-process-on-buffer "prettier" "--stdin-filepath" buffer-file-name))
(add-hook 'markdown-mode-hook (lambda () (add-hook 'before-save-hook #'prettier-format-buffer nil t)))

;; start server
(require 'server)
(server-start)

;; end
(provide 'default)
;;; default.el ends here
