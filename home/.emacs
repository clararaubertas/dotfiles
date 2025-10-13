(message "hi")

(require 'package)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(setq use-package-always-ensure t)
(eval-and-compile
  (setq use-package-always-ensure t
        use-package-expand-minimally t))

(use-package diminish
  :ensure t
  )

(use-package smartparens
  :diminish (smartparens-mode .  "()")

  :hook (prog-mode text-mode markdown-mode) ;; add `smartparens-mode` to these hooks
  :init
  ;;  (use-package smartparens-ruby)
  (add-hook 'ruby-mode-hook 'smartparens-strict-mode))

;; ( compilation-scroll-output t)
;; (setq compilation-auto-jump-to-first-error t)

;; (setq compilation-max-output-line-length nil)
(defun ar/colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region (point-min) (point-max))))

(add-hook 'compilation-filter-hook 'ar/colorize-compilation-buffer)


(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode))

(use-package magit
  :diminish (magit-mode  . " \ue702")
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-status)))


(use-package rainbow-delimiters
  :diminish
  :hook (prog-mode text-mode))

(use-package rainbow-mode
  :diminish
  :hook (prog-mode text-mode))



(use-package company
  :diminish (company-mode .  "\uec0d")
  :config (global-company-mode) )

(use-package css-mode
  :mode "\\.css\\'")
(use-package scss-mode
  :mode "\\.scss\\'")
(setq-default css-indent-offset 2)
(add-hook 'scss-mode-hook
          (lambda () (add-to-list 'write-file-functions 'delete-trailing-whitespace)))
(use-package web-mode
  :mode "\\.erb\\'"
  :mode "\\.html\\'"
  :mode "\\.php\\'"
  )


;;; \begin ruby

(use-package ruby-mode
  :mode "\\.rb\\'"
  :mode "\\.rake\\'"
  :mode "\\.gem\\'"
  :mode "Rakefile\\'"
  :mode "Gemfile\\'"
  :interpreter "ruby"

  :init
  (setq ruby-indent-level 2
        ruby-indent-tabs-mode nil)
  :bind
  (([(meta down)] . forward-sexp)
   ([(meta up)]   . backward-sexp)
   (("C-c C-e"    . ruby-send-region))))  ;; Rebind since Rubocop uses C-c C-r

(use-package inf-ruby
  :init
  (add-hook 'ruby-mode-hook 'inf-ruby-minor-mode))

(use-package flymake
  :diminish
  :init
  :hook (prog-mode text-mode markdown-mode)
  )


(use-package rvm
  :config
  (rvm-use-default))

(use-package bundler
  :config
  ;; (ha-local-leader 'ruby-mode-map
  ;;   "g"  '(:ignore t :which-key "bundler")
  ;;   "g o" '("open" . bundle-open)
  ;;   "g g" '("console" . bundle-console)
  ;;   "g c" '("check" . bundle-check)
  ;;   "g i" '("install" . bundle-install)
  ;;   "g u" '("update" . bundle-update)))
  )

(use-package rubocop
  :init
  :hook (ruby-mode))

(use-package rufo
  :hook (ruby-mode))

;; (use-package robe
;;   :config (global-robe-mode))

(use-package ruby-electric
  :hook (ruby-mode))

(use-package rspec-mode
  :hook (ruby-mode web-mode))

(eval-after-load 'rspec-mode
  '(rspec-install-snippets))

(use-package projectile
  :diminish
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  )



(use-package expand-region
  :bind ("C-=" . er/expand-region))


;;; \end ruby


(use-package all-the-icons)



(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  :init
  (setq dashboard-icon-type 'all-the-icons)

  (setq dashboard-startup-banner (random 4))
  )


(use-package sky-color-clock
  :ensure nil
  :load-path "/home/clara/.emacs.d/sky-color-clock"
  :config
  (sky-color-clock-initialize 41)
  (setq sky-color-clock-format "%k:%M")
  (setq sky-color-clock-enable-emoji-icon t)
    (push '(:eval (sky-color-clock)) (default-value 'global-mode-string))
  (display-time-mode -1))

(setq zone-programs [zone-pgm-drip])




;; (use-package spaceline :ensure t
;;   :config
;;   (setq-default powerline-height 80)
;;   (setq-default powerline-default-separator 'zigzag)
;;     (setq-default mode-line-format '("%e" (:eval (spaceline-ml-main))))
;;   )




;; (use-package spaceline-config :ensure spaceline
;;   :config
;;   ;;  (spaceline-spacemacs-theme)
;;   (spaceline-toggle-battery-on)
;;   (spaceline-toggle-major-mode-on)
;;   (spaceline-toggle-version-control-on)
;;   (spaceline-toggle-buffer-modified-on)
;;   (spaceline-toggle-minor-modes-on)
;;   (spaceline-toggle-flycheck-error-on)
;;   (spaceline-toggle-flycheck-info-on)
;;   )


(set-face-attribute 'mode-line-active nil :box 'unspecified)
(set-face-attribute 'mode-line-inactive nil :box 'unspecified)

;; (use-package doom-modeline
;;   :config
;;   (setq doom-modeline-buffer-file-name-style 'truncate-with-project)

;;   (setq doom-modeline-major-mode-icon t)
;;   (setq doom-modeline-icon t)
;;   (setq doom-modeline-time-analogue-clock t)
;;   (setq doom-modeline-time-live-icon t)
;;   (setq doom-modeline-battery t)
;;   (setq doom-modeline-env-version t)
;;   (setq doom-modeline-env-enable-ruby t)
;;   (setq doom-modeline-height 25)
;;   (setq doom-modeline-major-mode-color-icon t)
;;   (setq doom-modeline-github nil)
;;   (setq doom-modeline-minor-modes t)
;;   :init
;;   (doom-modeline-mode))



(set-face-attribute 'mode-line nil
                    :background "#353644"
                    :foreground "#d33682"
		    ;;                    :box '(:line-width 8 :color "#353644")
                    :overline nil
                    :underline nil)


(use-package diff-hl
  :ensure t
  :init
  :config

  (add-hook 'dired-mode-hook 'diff-hl-dired-mode)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  (setq diff-hl-fringe-bmp-function 'diff-hl-fringe-bmp-from-type)
  (setq diff-hl-margin-side 'left)
  (global-diff-hl-mode)
  (diff-hl-margin-mode t)
  (diff-hl-flydiff-mode t))

;; (use-package omnibox
;;   :config
;;   (global-set-key (kbd "M-x") 'omnibox-M-x)
;;   (omnibox-setup))

(use-package emojify
  :config
  (set-fontset-font
   t 'symbol (font-spec :family "Noto Emoji") nil 'prepend)
  (setq emojify-display-style 'unicode)
  (setq emojify-emoji-styles '(unicode))
  (bind-key* (kbd "C-c .") #'emojify-insert-emoji)) ; override binding in any mode

(use-package solarized-theme
  :init
  (load-theme 'solarized-dark t)
  ;; Use more italics
  (setq solarized-use-more-italic t)
  (set-face-foreground 'default "#fdf6e3") ; Normal
;; (set-face-foreground 'mode-line "#859900")
;; (set-face-foreground 'mode-line-inactive "#2aa198")
(set-face-background 'highlight "#073642")


  )

(use-package almost-mono-themes
  :config
  (load-theme 'almost-mono-black t))

(use-package nyan-mode
  :config (setq nyan-bar-length 5)
  :init (nyan-mode))



(global-display-line-numbers-mode)


(use-package idle-highlight-in-visible-buffers-mode
  :diminish
  :hook (prog-mode text-mode))

(use-package indent-bars
  :hook (prog-mode))

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic)))


(use-package vertico
  :config
  (setq vertico-cycle t
        vertico-resize nil

        vertico-scroll-margin 0 ;; Different scroll margi
        vertico-count 20 ;; Show more candidates
        vertico-resize t ;; Grow and shrink the Vertico minibuffer
        vertico-cycle t ;; Enable cycling for `vertico-next/previous'
        )
  :init
  (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))


;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
	      ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  (marginalia-mode))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(unless (package-installed-p 'vc-use-package)
  (package-vc-install "https://github.com/slotThe/vc-use-package"))
(require 'vc-use-package)

(use-package nerd-icons-mode-line
  :ensure t
  :vc (:fetcher github :repo "grolongo/nerd-icons-mode-line")
  :custom
  (nerd-icons-mode-line-v-adjust 0.1) ; default value
  (nerd-icons-mode-line-size 1.0) ; default value
  :config (nerd-icons-mode-line-global-mode t))


(use-package yasnippet
  :ensure t
  :hook ((text-mode
          prog-mode
          conf-mode
          snippet-mode) . yas-minor-mode-on)
  :init
  (setq yas-snippet-dir "~/.emacs.d/snippets"))

(use-package yasnippet-snippets ; Collection of snippets
  :ensure t)

;; font

(set-face-attribute 'default t :font "VictorMono Nerd Font 18" )

(set-frame-font "VictorMono Nerd Font 18" )


(global-font-lock-mode t)
(global-prettify-symbols-mode)



(setq default-frame-alist
      '((background-color . "#002b36")))

;;; B.L.I.N.K

(defvar blink-cursor-colors (list "#b58900" "#859900" "#268bd2")
  "On each blink the cursor will cycle to the next color in this list.")
(setq blink-cursor-count 0)
(defun blink-cursor-timer-function ()
  "Cyberpunk variant of timer `blink-cursor-timer'. OVERWRITES original version in `frame.el'.

This one changes the cursor color on each blink. Define colors in `blink-cursor-colors'."
  (when (not (internal-show-cursor-p))
    (when (>= blink-cursor-count (length blink-cursor-colors))
      (setq blink-cursor-count 0))
    (set-cursor-color (nth blink-cursor-count blink-cursor-colors))
    (setq blink-cursor-count (+ 1 blink-cursor-count))
    )
  (internal-show-cursor nil (not (internal-show-cursor-p)))
  )



(use-package request)
(use-package ewth
  :ensure nil
  :load-path "/home/clara/.emacs.d/ewth.el"
  :config
  (setq ewth-url "http://wttr.in/Chicago?u&format=1")
  (ewth-mode)
  )

(use-package fancy-battery
 :init (fancy-battery-mode))


(use-package moody
  :config
  (moody-replace-mode-line-front-space)
  (moody-replace-mode-line-buffer-identification)

  (moody-replace-vc-mode))



;;; files
;; Put autosave files (ie #foo#) and backup files (ie foo~) in
;; ~/.emacs.d/.
(defun my-backup-file-name (fpath)
  "Return a new file path of a given file path.
If the new path's directories does not exist, create them."
  (let* (
	 (backupRootDir "~/.emacs.d/emacs-backup/")
	 (filePath (replace-regexp-in-string "[A-Za-z]:" "" fpath ))         (backupFilePath (replace-regexp-in-string "//" "/" (concat backupRootDir filePath "~") ))
	 )
    (make-directory (file-name-directory backupFilePath) (file-name-directory backupFilePath))
    backupFilePath
    )
  )
(setq make-backup-file-name-function 'my-backup-file-name)

;;when saving files, set execute permission if #! is in first line.
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;;;;
(defun backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (delete-region (point) (progn (backward-word arg) (point))))
(define-key minibuffer-local-map [C-w] 'backward-delete-word)
(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)
(global-set-key  (kbd "C-;") 'comment-region)


;;;;

(use-package flycheck
  :ensure t
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

(global-visual-line-mode 1)
(diminish 'visual-line-mode)
(use-package eldoc :diminish)

(auto-fill-mode -1)
(remove-hook 'text-mode-hook 'turn-on-auto-fill)


;;; ..........
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(setq inhibit-startup-screen t)
(setq inhibit-splash-screen t)
(setq transient-mark-mode t)
(fset 'yes-or-no-p 'y-or-n-p)
(setq debug-on-error nil)
(setq inhibit-startup-echo-area-message "clara")
(setq initial-scratch-message nil)
(message "You're doing a great job!")


(message "world")

;; end
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(moody yasnippet-snippets web-mode vertico vc-use-package solarized-theme smartparens scss-mode rvm rufo ruby-electric rubocop rspec-mode robe request rainbow-mode rainbow-delimiters projectile orderless nyan-mode nerd-icons-mode-line nerd-icons-completion markdown-mode marginalia magit indent-bars idle-highlight-in-visible-buffers-mode flycheck fancy-battery expand-region emojify diminish diff-hl dashboard company bundler almost-mono-themes all-the-icons))
 '(package-vc-selected-packages
   '((nerd-icons-mode-line :vc-backend Git :url "https://github.com/grolongo/nerd-icons-mode-line")
     (vc-use-package :vc-backend Git :url "https://github.com/slotThe/vc-use-package"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
