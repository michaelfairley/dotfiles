; ido
(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t)

; whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(setq-default indent-tabs-mode nil)
(setq tab-width 2)
(setq c-basic-offset 2)
(setq rust-indent-offset 2)

(global-set-key (kbd "C-j") 'newline-and-indent)

; package
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

; editing
(autoload 'zap-up-to-char "misc" "Kill up to, but not including ARGth occurrence of CHAR." t)
(global-set-key (kbd "M-z") 'zap-up-to-char)

(show-paren-mode 1)

(setq require-final-newline t)

; removing gui noise
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

; startup
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message "michaelfairley")

(setq compilation-always-kill t)

(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

(setq company-idle-delay 0.2)
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

; rust
(setq racer-rust-src-path "/Users/michaelfairley/os/rust/src")

(add-hook 'rust-mode-hook
          '(lambda ()
             (racer-mode)
             (eldoc-mode)
             (company-mode)
             (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
             (flycheck-mode)
             (cargo-minor-mode)
             (local-set-key (kbd "M-.") #'racer-find-definition)
             (local-set-key (kbd "TAB") #'company-indent-or-complete-common)))
