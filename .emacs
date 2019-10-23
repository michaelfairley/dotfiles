; ido
(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t)

; whitespace

(defun nuke-trailing ()
  (add-hook 'before-save-hook 'delete-trailing-whitespace nil t))
(add-hook 'rust-mode-hook 'nuke-trailing)
(add-hook 'ruby-mode-hook 'nuke-trailing)
(add-hook 'toml-mode-hook 'nuke-trailing)
(add-hook 'haml-mode-hook 'nuke-trailing)


(setq-default indent-tabs-mode nil)
(setq tab-width 2)
(setq c-basic-offset 2)
(setq rust-indent-offset 2)
(setq css-indent-offset 2)
(setq js-indent-level 2)

(global-set-key (kbd "C-j") 'newline-and-indent)
(global-set-key (kbd "C-c C-c v") 'recompile)

; package
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

(setq load-prefer-newer t)

; editing
(autoload 'zap-up-to-char "misc" "Kill up to, but not including ARGth occurrence of CHAR." t)
(global-set-key (kbd "M-z") 'zap-up-to-char)

(show-paren-mode 1)

(setq require-final-newline t)

(global-set-key (kbd "M-;") 'comment-dwim-2)

(global-set-key (kbd "C-;") 'avy-goto-char-2)

; removing gui noise
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

; startup
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message "michaelfairley")

; compilation
(setq compilation-always-kill t)
(push '("\\*compilation\\*" . (nil (reusable-frames . t))) display-buffer-alist)


(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

(setq company-idle-delay nil)
(setq company-minimum-prefix-length 2)

; windows
(windmove-default-keybindings)

; compliation
; From http://stackoverflow.com/questions/1292936/line-wrapping-within-emacs-compilation-buffer
(defun compilation-mode-no-truncate-hook ()
  (setq truncate-lines nil)
  (set (make-local-variable 'truncate-partial-width-windows) nil))
(add-hook 'compilation-mode-hook 'compilation-mode-no-truncate-hook)

(setq compilation-ask-about-save nil)

; backup
; From http://stackoverflow.com/questions/151945/how-do-i-control-how-emacs-makes-backup-files
(defvar --backup-directory (concat user-emacs-directory "backups"))
(if (not (file-exists-p --backup-directory))
    (make-directory --backup-directory t))
(setq backup-directory-alist `(("." . ,--backup-directory)))
(setq make-backup-files t               ; backup of a file the first time it is saved.
      backup-by-copying t               ; don't clobber symlinks
      version-control t                 ; version numbers for backup files
      delete-old-versions t             ; delete excess backup files silently
      delete-by-moving-to-trash t
      kept-old-versions 6               ; oldest versions to keep when a new numbered backup is made (default: 2)
      kept-new-versions 9               ; newest versions to keep when a new numbered backup is made (default: 2)
      auto-save-default t               ; auto-save every buffer that visits a file
      auto-save-timeout 20              ; number of seconds idle time before auto-save (default: 30)
      auto-save-interval 200            ; number of keystrokes between auto-saves (default: 300)
      )

; rust
(add-hook 'rust-mode-hook
          '(lambda ()
             (racer-mode)
             (eldoc-mode)
             (company-mode)
             (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
             (flycheck-mode)
             (cargo-minor-mode)
             (local-set-key (kbd "TAB") #'company-indent-or-complete-common)))
(push '("\\*Cargo Build\\*" . (nil (reusable-frames . t))) display-buffer-alist)
(push '("\\*Cargo Run\\*" . (nil (reusable-frames . t))) display-buffer-alist)

(setenv "CARGO_INCREMENTAL" "1")
(setenv "RUST_BACKTRACE" "full")

(with-eval-after-load "cargo-process"
  (defalias 'cargo-process--start2 (symbol-function 'cargo-process--start))
  (defun cargo-process--start (name command &optional last-cmd)
    (cargo-process--start2 "Build" command last-cmd))
  (defun cargo-process-build-lib ()
    (interactive)
    (cargo-process--start "Build lib" "build --lib"))
  (defun cargo-process-run ()
    (interactive)
    (cargo-process--start2 "Run" "run")))

(with-eval-after-load "cargo"
  (define-key cargo-minor-mode-map (kbd "C-c C-c C-v") 'cargo-process-build-lib))

(add-hook 'glsl-mode-hook
          '(lambda ()
             (cargo-minor-mode)))

(add-hook 'toml-mode-hook
          '(lambda ()
             (cargo-minor-mode)))

(setq rust-match-angle-brackets nil)

; ruby
(push '("\\*rspec-compilation\\*" . (nil (reusable-frames . t))) display-buffer-alist)
(add-hook 'haml-mode-hook
          '(lambda ()
             (rspec-verifiable-mode)))
(setq ruby-deep-indent-paren nil)


; magit
(global-set-key (kbd "C-x g") 'magit-status)



(require 'ansi-color)
(defun my-colorize-compilation-buffer ()
  (ansi-color-apply-on-region compilation-filter-start (point-max)))
(add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (terraform-mode toml-mode deferred))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
