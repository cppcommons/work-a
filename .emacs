(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(make-backup-files nil)
 '(package-selected-packages (quote (flycheck d-mode use-package highlight-parentheses))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

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

(package-initialize)
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.org/packages/")
        ("org" . "http://orgmode.org/elpa/")))

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

                                        ;(use-package flycheck :ensure t)

(load-file "~/flycheck.el")

;(add-to-list 'exec-path (expand-file-name "/cygpath/c/D/dmd2/windows/bin"))
(add-to-list 'exec-path (expand-file-name "/c/D/dmd2/windows/bin"))

'(flycheck-define-checker d-dmd
  "A D syntax checker using the DMD compiler.

Requires DMD 2.066 or newer.  See URL `http://dlang.org/'."
  :command ("dmd"
            "-debug"                    ; Compile in debug mode
            "-o-"                       ; Don't generate an object file
            "-vcolumns"                 ; Add columns in output
            "-wi" ; Compilation will continue even if there are warnings
            (eval (concat "-I" (flycheck-d-base-directory)))
            (option-list "-I" flycheck-dmd-include-path concat)
            (eval flycheck-dmd-args)
            (eval (shell-command-to-string (concat "cygpath " source)))
            )
  :error-patterns
  ((error line-start
          (file-name) "(" line "," column "): Error: " (message)
          line-end)
   (warning line-start (file-name) "(" line "," column "): "
            (or "Warning" "Deprecation") ": " (message) line-end)
   (info line-start (file-name) "(" line "," column "): "
         (one-or-more " ") (message) line-end))
  :modes d-mode)

(defun flycheck-checker-shell-command (checker)
  "Get a shell command for CHECKER.

Perform substitution in the arguments of CHECKER, but with
`flycheck-substitute-shell-argument'.

Return the command of CHECKER as single string, suitable for
shell execution."
  ;; Note: Do NOT use `combine-and-quote-strings' here.  Despite it's name it
  ;; does not properly quote shell arguments, and actually breaks for special
  ;; characters.  See https://github.com/flycheck/flycheck/pull/522
  (let* ((args (apply #'append
                      (seq-map (lambda (arg)
                                 (if (memq arg '(source source-inplace source-original))
                                     (progn
                                       (xyz)
                                       (message "AAA")
                                       (list
                                        ;(concat "`cygpath -w" (buffer-file-name) "`")
                                        (shell-command-to-string (concat "cygpath " (buffer-file-name)))
                                        )
                                       )
                                   (flycheck-substitute-argument arg checker)))
                               (flycheck-checker-arguments checker))))
         (command (mapconcat
                   #'shell-quote-argument
                   (funcall flycheck-command-wrapper-function
                            (cons (flycheck-checker-executable checker) args))
                   " ")))
    (if (flycheck-checker-get checker 'standard-input)
        ;; If the syntax checker expects the source from standard input add an
        ;; appropriate shell redirection
        (concat command " < " (shell-quote-argument (buffer-file-name)))
      command)))

(global-flycheck-mode)
