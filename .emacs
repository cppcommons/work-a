(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(make-backup-files nil)
 '(package-selected-packages
   (quote
    (flycheck-d-unittest flycheck d-mode use-package highlight-parentheses))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:background "black" :foreground "#55FF55"))))
 '(cursor ((((class color) (background dark)) (:background "#00AA00")) (((class color) (background light)) (:background "#999999")) (t nil))))

(put 'erase-buffer 'disabled nil)

(when (eq window-system 'w32)
  (custom-set-faces
   '(default ((t
               (:background "black" :foreground "#55FF55")
               )))
   '(cursor ((((class color)
               (background dark))
              (:background "#00AA00"))
             (((class color)
               (background light))
              (:background "#999999"))
             (t ())
             )))
  )

;(global-hl-line-mode t)

(require 'package)
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.org/packages/")
        ("org" . "http://orgmode.org/elpa/")))
(package-initialize)
(unless package-archive-contents (package-refresh-contents))
(unless (package-installed-p 'use-package)
    (package-install 'use-package))
;初めてuse-packageを使う方は
;以下のコマンドを実行します。
;
;M-x package-install use-package

'(use-package beacon
  :ensure t
  :pin melpa
  :config
  (beacon-mode 1)
  )

(use-package highlight-parentheses
  :ensure t
  :pin melpa
  :init
  (setq hl-paren-background-colors '("orangered4"))
  (setq hl-paren-colors '("black"))
  :config
  (define-globalized-minor-mode global-highlight-parentheses-mode highlight-parentheses-mode
    (lambda nil (highlight-parentheses-mode t)))
  (global-highlight-parentheses-mode t)
  )

(use-package whitespace
  :ensure t
  :init
  '(setq whitespace-style '(face spaces tabs trailing lines space-before-tab newline indentation space-after-tab space-mark tab-mark newline-mark))
  (if (eq window-system 'w32)
      (setq whitespace-style '(face spaces tabs trailing lines space-before-tab newline indentation space-after-tab space-mark tab-mark))
    (setq whitespace-style '(face spaces tabs trailing lines space-before-tab newline indentation space-after-tab tab-mark)))
  '(setq global-whitespace-mode t)
  :config
  (global-whitespace-mode t)
  (whitespace-mode)
  :bind
  (([f12] . whitespace-mode)
   ([(shift f12)] . global-whitespace-mode)))

(setq-default tab-width 4 indent-tabs-mode nil)

'(when (and (not window-system)
           (string-match "^xterm" (getenv "TERM")))
  (require 'xterm-title)
  (xterm-title-mode 1))

(setq inhibit-startup-screen t)

;(progn (shell) (delete-other-windows))

(use-package d-mode :ensure t)
(add-hook 'd-mode-hook
          (lambda ()
            (setq-local flycheck-checker 'd-dmd)
            (local-set-key  (kbd "C-c C-p") 'flycheck-previous-error)
            (local-set-key  (kbd "C-c C-n") 'flycheck-next-error)))

(use-package flycheck :ensure t)

;(load-file "~/flycheck.el")

;(add-to-list 'exec-path (expand-file-name "/cygpath/c/D/dmd2/windows/bin"))
(add-to-list 'exec-path (expand-file-name "~/dmd2/linux/bin64"))
(add-to-list 'exec-path "/c/D/dmd2/windows/bin")


(global-flycheck-mode)

(use-package flycheck-d-unittest :ensure t)
(require 'flycheck-d-unittest)
(setup-flycheck-d-unittest)
