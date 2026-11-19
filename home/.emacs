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

(use-package magit-delta)

;; Matrix client — SMS via the mautrix-gmessages bridge on matrix.parallactic.com.
;; M-x ement-connect, then M-x ement-list-rooms.
;; Saved session (~/.cache/ement.el) so the daemon reconnects without a password;
;; comms.sh opens the sms frame at login.
(use-package ement
  :commands (ement-connect ement-list-rooms ement-room-list)
  :custom (ement-save-sessions t))

;; M-x sms — plain list of text conversations on top of Ement (~/.emacs.d/sms/sms.el).
(use-package sms
  :ensure nil
  :load-path "/home/clara/.emacs.d/sms"
  :commands sms)

(use-package which-key
  :init (which-key-mode))

(use-package auto-package-update
  :config
  (setq auto-package-update-prompt-before-update t)
  (setq auto-package-update-delete-old-versions t)
  :init
  (auto-package-update-maybe)
  (add-hook 'auto-package-update-before-hook
            (lambda () (message "I will update packages now"))))

(use-package rainbow-delimiters
  :diminish
  :hook (prog-mode text-mode))

(use-package rainbow-mode
  :diminish
  :hook (prog-mode text-mode))

(setq native-comp-async-report-warnings-errors 'silent)

(use-package company
  :diminish (company-mode .  " \uec0d")
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
  ;; add-to-list, not push: re-evaluating .emacs mustn't add a second clock
  (add-to-list 'global-mode-string '(:eval (sky-color-clock)))
  (display-time-mode -1))

(setq zone-programs [zone-pgm-drip])



(set-face-attribute 'mode-line-active nil :box 'unspecified)
(set-face-attribute 'mode-line-inactive nil :box 'unspecified)

(use-package doom-modeline
  :config
  (setq doom-modeline-buffer-file-name-style 'truncate-with-project)
  (setq doom-modeline-buffer-state-icon t)
  (setq doom-modeline-buffer-modification-icon t)
  (setq doom-modeline-major-mode-icon t)
  (setq doom-modeline-icon t)
  (setq doom-modeline-time-analogue-clock t)
  (setq doom-modeline-time-live-icon t)
  (setq doom-modeline-project-detection 'auto)
  (setq doom-modeline-env-version t)
  (setq doom-modeline-env-enable-ruby t)
  (setq doom-modeline-height 25)
  (setq doom-modeline-major-mode-color-icon t)
  (setq doom-modeline-github nil)
  (setq doom-modeline-minor-modes t)
  (setq doom-modeline-enable-buffer-position t)
  (setq doom-modeline-position-line-format '("L%l"))
  (doom-modeline-mode))




(use-package diff-hl
  :ensure t
  :init
  :config

  (add-hook 'dired-mode-hook 'diff-hl-dired-mode)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  (setq diff-hl-fringe-bmp-function 'diff-hl-fringe-bmp-from-type)
  (setq diff-hl-margin-side 'left)
  (global-diff-hl-mode)
  (diff-hl-margin-mode nil)
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


(use-package ef-themes
  :ensure t
  :init
  ;; This makes the Modus commands listed below consider only the Ef
  ;; themes.  For an alternative that includes Modus and all
  ;; derivative themes (like Ef), enable the
  ;; `modus-themes-include-derivatives-mode' instead.  The manual of
  ;; the Ef themes has a section that explains all the possibilities:
  ;;
  ;; - Evaluate `(info "(ef-themes) Working with other Modus themes or taking over Modus")'
  ;; - Visit <https://protesilaos.com/emacs/ef-themes#h:6585235a-5219-4f78-9dd5-6a64d87d1b6e>

  (ef-themes-take-over-modus-themes-mode 1)
  :bind
  (("<f5>" . modus-themes-rotate)
   ("C-<f5>" . modus-themes-select)
   ("M-<f5>" . modus-themes-load-random))
  :config
  ;; All customisations here.
  (set-face-attribute 'default t :font
		      "IosevkaTermSlab NF 11" )
  (setq modus-themes-mixed-fonts t)
  (setq modus-themes-italic-constructs t)

  ;; Use them in overrides
  (setq modus-themes-common-palette-overrides
	'(
	  (bg-main  "#002b36")
	  (fg-main  "#EEE8D5")
	  (default "#fdf6e3")
	  (solar-red  "#DC322F")
	  (red  "#DC322F")
	  (solar-green  "#859900")
	  (green  "#859900")
	  (yellow  "#B58900")
	  (solar-yellow  "#B58900")
	  (cyan-cooler  "#268BD2")
	  (solar-magenta "#D33682")
	  (cyan-warmer  "#2AA198")
	  (violet "#6c71c4")
	  (orange "#cb4b16")
	  (bg-region solar-yellow)
;;	  (comment solar-magenta)
	   (fg-mode-line-active solar-magenta)
	   (bg-mode-line-active "#030602")
	  (comment solar-magenta)
	  (font-lock-function-call-face solar-yellow)
	  (font-lock-function-name-face solar-green)
	  (rainbow-0 solar-yellow)
	  (rainbow-1 cyan-warmer)
	  (rainbow-2 cyan-cooler)
	  (rainbow-3 violet)
	  (rainbow-4 orange)
	  (flycheck-error-list-info solar-green)

	  (set-face-foreground 'flycheck-error-list-info solar-green)
	  (rainbow-5 solar-yellow)
	  (rainbow-6 blue)
	  
	  (rainbow-7 cyan)
	  (rainbow-8 magenta)
	  ))


  ;; Finally, load your theme of choice (or a random one with
  ;; `modus-themes-load-random', `modus-themes-load-random-dark',
  ;; `modus-themes-load-random-light').
  ;; ef-bio
  (modus-themes-load-theme 'ef-maris-dark) )





  (set-face-attribute 'line-number nil
                    :background "#353644"
                    :foreground "#d33682"
		    :box nil
		    :font "IosevkaTermSlab NF 10"
                    :overline nil
                    :underline nil)
 (set-face-attribute 'line-number-current-line nil
                    :background "#353644"
                    :foreground "#268bd2"
		    :box nil
		    :slant 'italic
		    :font "IosevkaTermSlab NF 10"
                    :overline nil
                    :underline nil)

(set-face-attribute 'mode-line nil
                    :background "#353644"
                    :foreground "#d33682"
		    :box nil
		    :font "IosevkaTermSlab NF 8"
                    :overline nil
                    :underline nil)
(set-face-attribute 'mode-line-active nil
		    :font "IosevkaTermSlab NF 8")
(set-face-attribute 'mode-line-inactive nil
		    :foreground "#353644"
		    :font "IosevkaTermSlab NF 8")

(let* ((variable-tuple
        ;; a daemon (emacs --daemon, started by swaygrid.sh) has no window system during
        ;; init, so x-list-fonts would error; assume the font is there
        (cond ((or (daemonp) (x-list-fonts "Iosevkatermslab")) '(:font "Iosevkatermslab NF"))
	      (nil (warn "Cannot find da font..."))))
       (base-font-color     (face-foreground 'default nil 'default))
       (headline           `(:inherit default :weight bold :foreground ,base-font-color)))

  (custom-theme-set-faces
   'user
   `(org-level-8 ((t (,@headline ,@variable-tuple :height 0.8 :weight normal :slant italic))))
   `(org-level-7 ((t (,@headline ,@variable-tuple :height 0.8 :weight normal))))
   `(org-level-6 ((t (,@headline ,@variable-tuple :height 0.9 :weight normal :slant italic))))
   `(org-level-5 ((t (,@headline ,@variable-tuple :height 0.9 :weight normal))))
   `(org-level-4 ((t (,@headline ,@variable-tuple :height 1.0 :weight normal :slant italic :foreground "#2aa198"))))
   `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.0 :weight normal :foreground "#268bd2"))))
   `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.0 :foreground "#6c71c4"))))
   `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.1  :underline t :foreground "#d33682")))
		 `(org-document-title ((t (,@headline ,@variable-tuple :height 1.2 :underline nil :foreground "#eeeeee"))
   )))))


(use-package nyan-mode
  :config (setq nyan-bar-length 3)
  :init (nyan-mode))

(global-display-line-numbers-mode)

(use-package idle-highlight-in-visible-buffers-mode
  :diminish
  :config (set-face-background 'idle-highlight-in-visible-buffers "#268BD2")
  :hook (prog-mode text-mode))

(use-package indent-bars
  :hook (prog-mode lisp-mode))


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






(setq
 ;; Edit settings
 org-auto-align-tags nil
 org-tags-column 0
 org-catch-invisible-edits 'show-and-error
 org-special-ctrl-a/e t
 org-insert-heading-respect-content t

 ;; Org styling, hide markup etc.
 org-hide-emphasis-markers t
 org-pretty-entities t
 org-agenda-tags-column 0
 org-ellipsis "…")



(global-org-modern-mode)
(setq org-startup-indented t)
(global-font-lock-mode t)
(global-prettify-symbols-mode)

(setq default-frame-alist
      '((background-color . "#002b36")))

;;; B.L.I.N.K
(defvar blink-cursor-colors (list "#b58900" "#859900" "#268bd2")
  "On each blink the cursor will cycle to the next color in this list.")
(setq blink-cursor-count 0)
(defun blink-cursor-timer-function ()
  "Cyberpunk variant of timer `blink-cursor-timer'.
OVERWRITES original version in `frame.el'.
This one changes the cursor color on each blink.  Define colors in `blink-cursor-colors'."
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

;; (use-package fancy-battery
;;   :init (fancy-battery-mode))






;;; files
;; Put autosave files (ie #foo#) and backup files (ie foo~) in
;; ~/.emacs.d/.
(defun my-backup-file-name (fpath)
  "Return a new file path of a given file path FPATH.
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

;; Keep unmodified buffers in sync with their files on disk.
(global-auto-revert-mode 1)

;; Save file buffers automatically after 5 idle seconds, so the
;; "Save file …?" question (which can hide in another frame) rarely
;; comes up — but ONLY if the file hasn't changed on disk since the
;; buffer last read/saved it, so a stale buffer can never overwrite
;; newer edits made elsewhere.
(setq auto-save-visited-interval 5
      auto-save-visited-predicate
      (lambda () (verify-visited-file-modtime (current-buffer))))
(auto-save-visited-mode 1)

;; No stacked prompts: a prompt opened in one frame while another is
;; waiting in a different frame made input look frozen (C-g only
;; cancels one level).  Set after init so nothing turns it back on.
(add-hook 'after-init-hook
          (lambda () (setq enable-recursive-minibuffers nil)))

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

;; Built-in latex-mode: C-c C-f builds a PDF, C-c C-v opens it (default was dvi2tty).
;; TeX Live lives in ~/texlive (see ~/.profile for PATH).
(setq latex-run-command "lualatex"   ; lualatex so fontspec/system fonts work
      tex-print-file-extension ".pdf"
      tex-dvi-view-command "xdg-open *")


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
   '(all-the-icons almost-mono-themes auto-package-update bundler
		   color-theme-sanityinc-solarized company dashboard
		   diff-hl diminish doom-modeline ement emojify
		   expand-region fancy-battery flycheck
		   idle-highlight-in-visible-buffers-mode indent-bars
		   magit magit-delta marginalia markdown-mode
		   mode-line-nerd-icon modus-themes moody
		   nerd-icons-completion nerd-icons-mode-line
		   nyan-mode orderless org-modern php-mode projectile
		   rainbow-delimiters rainbow-mode request robe
		   rspec-mode rubocop ruby-electric rufo rvm scss-mode
		   smartparens solarized-theme sudo-edit
		   vc-use-package vertico web-mode which-key
		   yasnippet-snippets))
 '(package-vc-selected-packages
   '((vc-use-package :vc-backend Git :url
		     "https://github.com/slotThe/vc-use-package")
     (nerd-icons-mode-line :vc-backend Git :url
			   "https://github.com/grolongo/nerd-icons-mode-line"))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:background nil))))
 '(org-level-1 ((t (:inherit default :weight bold :foreground "unspecified-fg" :font "Iosevkatermslab NF" :height 1.1 :underline t :foreground "#d33682"))))
 '(org-level-2 ((t (:inherit default :weight bold :foreground "unspecified-fg" :font "Iosevkatermslab NF" :height 1.0 :foreground "#6c71c4"))))
 '(org-level-3 ((t (:inherit default :weight bold :foreground "unspecified-fg" :font "Iosevkatermslab NF" :height 1.0 :weight normal :foreground "#268bd2"))))
 '(org-level-4 ((t (:inherit default :weight bold :foreground "unspecified-fg" :font "Iosevkatermslab NF" :height 1.0 :weight normal :slant italic :foreground "#2aa198"))))
 '(org-level-5 ((t (:inherit default :weight bold :foreground "unspecified-fg" :font "Iosevkatermslab NF" :height 0.9 :weight normal))))
 '(org-level-6 ((t (:inherit default :weight bold :foreground "unspecified-fg" :font "Iosevkatermslab NF" :height 0.9 :weight normal :slant italic))))
 '(org-level-7 ((t (:inherit default :weight bold :foreground "unspecified-fg" :font "Iosevkatermslab NF" :height 0.8 :weight normal))))
 '(org-level-8 ((t (:inherit default :weight bold :foreground "unspecified-fg" :font "Iosevkatermslab NF" :height 0.8 :weight normal :slant italic)))))

