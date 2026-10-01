;;; emacs --- emacs configuration

;;; Commentary:
;;; editor macros

;;; Code:

;; hide menu bar
(menu-bar-mode 0)

;; hide tool bar
(tool-bar-mode 0)

;; hide scroll bar
(scroll-bar-mode 0)
(horizontal-scroll-bar-mode 0)

;; hide tooltips
(tooltip-mode 0)

;; use minibuffer instead of popups
(setq use-dialog-box nil)
(setq use-file-dialog nil)

;; hide context menus
(context-menu-mode 0)

;; hide mouse-driven menus
(global-set-key [C-down-mouse-1] #'ignore)
(global-set-key [C-down-mouse-2] #'ignore)
(global-set-key [C-down-mouse-3] #'ignore)
(global-set-key [S-down-mouse-1] #'ignore)

;; line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; column numbers
(column-number-mode 1)

;; dont highlight current line
(global-hl-line-mode 0)

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
      corfu-auto-delay 0.1
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

;; format-mode - format a buffer
(defvar-local format-mode-function nil)

(defun format-mode--format-buffer () (when format-mode-function (funcall format-mode-function)))

(define-minor-mode format-mode
  "Format the current buffer on save."
  :lighter " Fmt"
  (if format-mode
      (add-hook 'before-save-hook #'format-mode--format-buffer nil t)
    (remove-hook 'before-save-hook #'format-mode--format-buffer t)))

(defun black-format-buffer ()
  "Format the current buffer with black."
  (interactive)
  (call-process-on-buffer
   "black" "-q" "--stdin-filename" buffer-file-name "-"))

(defun nixfmt-format-buffer ()
  "Format the current buffer with nixfmt."
  (interactive)
  (call-process-on-buffer
   "nixfmt" "-"))

(defun rustfmt-format-buffer ()
  "Format the current buffer with rustfmt."
  (interactive)
  (call-process-on-buffer
   "rustfmt" "--emit" "stdout"))

(defun gofmt-format-buffer ()
  "Format the current buffer with gofmt."
  (interactive)
  (call-process-on-buffer
   "gofmt"))

(defun prettier-format-buffer ()
  "Format the current buffer with prettier."
  (interactive)
  (call-process-on-buffer
   "prettier" "--stdin-filepath" buffer-file-name))

;; languages

;; nix - mode
(autoload 'nix-mode "nix-mode" "Major mode for Nix." t)
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))
;; nix - nixd lsp
(add-hook 'nix-mode-hook #'eglot-ensure)
(with-eval-after-load 'eglot (add-to-list 'eglot-server-programs '(nix-mode . ("nixd"))))
;; nix - nixfmt formatter
(add-hook 'nix-mode-hook (lambda () (setq-local format-mode-function #'nixfmt-format-buffer) (format-mode 1)))

;; rust - mode
(autoload 'rust-mode "rust-mode" "Major mode for Rust." t)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
;; rust - rust-analyzer lsp
(add-hook 'rust-mode-hook #'eglot-ensure)
(with-eval-after-load 'eglot (add-to-list 'eglot-server-programs '(rust-mode . ("rust-analyzer"))))
;; rust - rustfmt formatter
(add-hook 'rust-mode-hook (lambda () (setq-local format-mode-function #'rustfmt-format-buffer) (format-mode 1)))

;; go - go mode
(autoload 'go-mode "go-mode" "Major mode for Go." t)
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))
;; go - gopls lsp
(add-hook 'go-mode-hook #'eglot-ensure)
(with-eval-after-load 'eglot (add-to-list 'eglot-server-programs '(go-mode . ("gopls"))))
;; go - gofmt formatter
(add-hook 'go-mode-hook (lambda () (setq-local format-mode-function #'gofmt-format-buffer) (format-mode 1)))

;; python - pyright lsp
(add-hook 'python-mode-hook #'eglot-ensure)
(with-eval-after-load 'eglot (add-to-list 'eglot-server-programs '(python-mode . ("pyright-langserver" "--stdio"))))
;; python - black formatter
(add-hook 'python-mode-hook (lambda () (setq-local format-mode-function #'black-format-buffer) (format-mode 1)))

;; markdown - mode
(autoload 'markdown-mode "markdown-mode" "Major mode for Markdown." t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
;; markdown - marksman lsp
(add-hook 'markdown-mode-hook #'eglot-ensure)
(with-eval-after-load 'eglot (add-to-list 'eglot-server-programs '(markdown-mode . ("marksman"))))
;; markdown - prettier formatter
(add-hook 'markdown-mode-hook (lambda () (setq-local format-mode-function #'prettier-format-buffer) (format-mode 1)))

;; end
(provide 'default)
;;; default.el ends here
