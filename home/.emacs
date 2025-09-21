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

(use-package diminish)

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
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-status)))


(use-package rainbow-delimiters
  :diminish
  :hook (prog-mode text-mode))

(use-package rainbow-mode
  :diminish
  :hook (prog-mode text-mode))



(use-package company
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

(use-package robe
  :config (global-robe-mode))

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

;; or
(use-package all-the-icons)



(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  :init
  (setq dashboard-icon-type 'all-the-icons)

  (setq dashboard-startup-banner (random 4))
  )



(use-package smart-mode-line
  
  :init
  (setq sml/no-confirm-load-theme t)

  (setq sml/theme 'dark)
  (setq sml/name-width 20)
  (setq sml/mode-width 'full)
  (sml/setup)

  (setq display-time-day-and-date t)
  (setq display-time-format "  %I:%M %p  %a %e %b ")
  (setq display-time-default-load-average nil)
  (set-face-attribute 'mode-line nil :font "VictorMono Nerd Font-11:weight=bold")

  (display-time-mode)
  )
(use-package ewth
  :ensure nil
  :load-path "/home/clara/.emacs.d/ewth.el"
  :config
  (setq ewth-url "http://wttr.in/Chicago?u&format=2")
  (ewth-mode)
  )

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



(use-package emojify
  :config
  (set-fontset-font
   t 'symbol (font-spec :family "Noto Emoji") nil 'prepend)
  (setq emojify-display-style 'unicode)
  (setq emojify-emoji-styles '(unicode))
  (bind-key* (kbd "C-c .") #'emojify-insert-emoji)) ; override binding in any mode

(load-theme 'solarized-dark t)
(set-face-foreground 'default "#fdf6e3") ; Normal
(set-face-foreground 'mode-line "#859900")
(set-face-foreground 'mode-line-inactive "#2aa198")
(set-face-background 'highlight "#073642")


(use-package almost-mono-themes
  :config
  (load-theme 'almost-mono-black t))

(use-package nyan-mode
  :init (nyan-mode))


(use-package fancy-battery
  :init (fancy-battery-mode))

(global-display-line-numbers-mode)


(use-package idle-highlight-in-visible-buffers-mode
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

(use-package consult
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
  )
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

(set-face-attribute 'default t :font "VictorMono Nerd Font 13" )

(set-frame-font "VictorMono Nerd Font 13" )


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
(diminish 'eldoc-mode)
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
 '(custom-safe-themes
   '("fc1275617f9c8d1c8351df9667d750a8e3da2658077cfdda2ca281a2ebc914e0" default))
 '(flycheck-checker-error-threshold 500)
 '(indent-tabs-mode nil)
 '(package-selected-packages
   '(smart-mode-line spaceline-ml-all-the-icons fancy-battery spaceline-config spaceline-all-the-icons spaceline nyan-mode doom-modeline almost-mono-themes all-the-icons dashboard scss-mode vc-use-package nerd-icons-mode-line nerd-icons-completion nerd-icons orderless magit expand-region yasnippet-snippets rspec yasnippet marginalia consult rufo vertico rspec-mode yaml-mode web-mode undo-tree unbound smartparens rvm ruby-electric rubocop robe rinari rainbow-mode rainbow-delimiters projectile pretty-lambdada php-mode php+-mode paredit notify mwe-log-commands markdown-mode indent-guide indent-bars idle-highlight-mode idle-highlight-in-visible-buffers-mode highline highlight-tail highlight-indentation flymake-ruby flycheck exec-path-from-shell dired-details diminish dash company color-theme-solarized color-theme closure-template-html-mode cl-libify bundler anything-exuberant-ctags))
 '(package-vc-selected-packages
   '((nerd-icons-mode-line :vc-backend Git :url "https://github.com/grolongo/nerd-icons-mode-line")
     (vc-use-package :vc-backend Git :url "https://github.com/slotThe/vc-use-package"))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
