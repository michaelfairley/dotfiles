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
