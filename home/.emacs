;; it's clara's .emacs

;;;;;;;;;; I. Package Management ;;;;;;;;;;



(require 'package)

(add-to-list 'package-archives '("melpa"  . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/"))
(setq package-archive-priorities '(("melpa"  . 3)
                                   ("gnu"    . 2)))


(package-initialize)




(add-to-list 'load-path "~/.emacs.d/*")
(add-to-list 'custom-theme-load-path "~/.emacs.d/emacs-color-theme-solarized/")
(add-to-list 'load-path "~/.emacs.d/org-sync")

(mapc 'load
      '("os" "os-github"))
(setq os-github-auth '("clararaubertas" . "poppyasm"))
;;(require 'org-agenda-property)
;;(require 'android-mode)


(projectile-mode +1)
;; Recommended keymap prefix on macOS
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
;; Recommended keymap prefix on Windows/Linux
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)



;;;;;;;;;; ;;;;;;;;;;

;;;;;;;;;; III. COLORS!!!!! ;;;;;;;;;;

(set-face-attribute 'default t :font "Victor Mono SemiBold 15" )

(set-frame-font "Victor Mono SemiBold 15" )


(define-globalized-minor-mode my-global-idle-highlight-mode idle-highlight-mode
  (lambda () (idle-highlight-mode 1)))
(my-global-idle-highlight-mode 1)

(define-globalized-minor-mode my-global-blink-cursor-mode blink-cursor-mode
  (lambda () (blink-cursor-mode 1)))
(my-global-blink-cursor-mode 1)

(rainbow-delimiters-mode)
(electric-pair-mode)

(setq idle-highlight-idle-time 0)


(global-font-lock-mode t)
(global-prettify-symbols-mode)

(add-hook 'prog-mode-hook 'paredit-mode)

(load-theme 'solarized-dark t)
(set-face-foreground 'default "#fdf6e3") ; Normal
(set-face-foreground 'mode-line "#859900")
(set-face-foreground 'mode-line-inactive "#2aa198")
(set-face-background 'highlight "#073642")
(set-face-foreground 'highlight nil)
(set-face-background 'idle-highlight "#859900")
(set-face-foreground 'idle-highlight nil)
(setq default-frame-alist
      '((background-color . "#002b36")))

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






;;;;;;;;;; END Colors ;;;;;;;;;;


;;;;;;;;;; IV. Saving & Permissions ;;;;;;;;;;
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
;;;;;;;;;; ;;;;;;;;;;


(autoload 'scpaste "scpaste" "Paste the current buffer." t nil)
(setq scpaste-http-destination "http://clararaubertas.net"
      scpaste-scp-destination "clara@kumquat:/var/www/clararaubertas/")


;; (flx-ido-mode)
;; ;; Display ido results vertically, rather than horizontally
;; (setq ido-decorations (quote ("\n-> " "" "\n   " "\n   ..." "[" "]" " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]")))
;; (defun ido-disable-line-truncation () (set (make-local-variable 'truncate-lines) nil))
;; (add-hook 'ido-minibuffer-setup-hook 'ido-disable-line-truncation)
;; (defun ido-define-keys () ;; C-n/p is more intuitive in vertical layout
;;   (define-key ido-completion-map (kbd "C-n") 'ido-next-match)
;;     (define-key ido-completion-map (kbd "C-p") 'ido-prev-match))
;;   (add-hook 'ido-setup-hook 'ido-define-keys)


;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)



(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t)
(allout-mode)

(global-set-key [(control .)] 'goto-last-change)
					; M-. can conflict with etags tag search. But C-. can get overwritten
					; by flyspell-auto-correct-word. And goto-last-change needs a really
					; fast key.
(global-set-key [(meta .)] 'goto-last-change)
;; buffrs
;; set up ibuffer
 (autoload 'ibuffer "ibuffer" "List buffers." t)
 (setq ibuffer-default-sorting-mode 'major-mode)


;; ;; uniquify
;; (require 'uniquify)
;; (setq uniquify-buffer-name-style 'forward)
;; ;; Remap common buffer bindings to ibuffer and iswitchb

;; (define-key global-map "\C-x\C-b" 'ibuffer-other-window)

;;;;;;;;;; VI. Ruby preferences ;;;;;;;;;;
;; (setq rsense-home "/opt/rsense-0.3")
;; (add-to-list 'load-path (concat rsense-home "/etc"))
;; (require 'rsense)
(add-to-list 'load-path "~/.emacs.d/rinari")
(require 'rinari)

;; (defun ruby-insert-end () 
;;   "Insert \"end\" at point and reindent current line." 
;;   (interactive) 
;;   (insert "end") 
;;   (ruby-indent-line t) 
;;   (end-of-line))

(require 'yaml-mode)
(add-to-list 'load-path "~/.emacs.d/rhtml")
(require 'rhtml-mode)
(add-hook 'haml-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)
            (define-key haml-mode-map "\C-m" 'newline-and-indent)))
(add-to-list 'interpreter-mode-alist '("ruby" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.r\\(b\\(w\\|x\\)?\\|html?\\|js\\)$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\([Rr]ake\\|[Cc]ap\\|[Gg]em\\)file$" . ruby-mode))

(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gem\\(spec\\)?$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))

(require 'flymake-ruby)
(add-hook 'ruby-mode-hook 'flymake-ruby-load)


(add-hook 'ruby-mode-hook '(lambda ()
			     (setq ruby-deep-arglist t)
			     (setq ruby-deep-indent-paren nil)
			     (esk-paredit-nonlisp)
			     (ruby-electric-mode)
			     (rspec-mode)
			     (rubocop-mode)
			     (ruby-tools-mode)
			     (ruby-end-mode)
			     (local-set-key [S-f7] 'ruby-compilation-this-buffer)
			     (define-key ruby-mode-map (kbd "RET") 'reindent-then-newline-and-indent)
			     (define-key ruby-mode-map (kbd "TAB") 'indent-for-tab-command)
			     (local-set-key [f7] 'ruby-compilation-this-test)
			     (local-set-key [f6] 'recompile)
			     (local-set-key (kbd "C-c .") 'rsense-complete)
			     (add-to-list 'ac-sources 'ac-source-rsense-method)
			     (add-to-list 'ac-sources
					  'ac-source-rsense-constant)
			     ))

;;;;;;;;;; end RUBY section ;;;;;;;;;;


;; ;;;;;;;;;; V. ORG MODE ;;;;;;;;;;
;; (setq-default major-mode 'org-mode)
;; (setq org-startup-indented t)

;; (setq org-todo-keywords
;;       (quote ((sequence "TODO(t)" "|" "DONE(d!)")
;;               (sequence "WAITING(w)" "SOMEDAY/MAYBE(m)" "JESSE(j)" "PROJECT(p)" "|" "CANCELLED(c)")
;; )))
;; (setq org-todo-keyword-faces      (quote (
;;                     ("TODO" ( :background "#859900" :weight bold :foreground "#002b36"))
;;                     ("WAITING" (  :weight bold :foreground "#fdf6e3"))
;;                     ("SOMEDAY/MAYBE" (  :weight bold :foreground "#2aa198"))
;;                     ("DONE" (  :weight bold :foreground "#859900"))
;;                     ("PROJECT" ( :background "#2aa198" :weight bold  :foreground "#002b36"))
;;                     ("JESSE" ( :weight bold :foreground "#fdf6e3"))
;;                     ("CANCELLED" (  :weight bold :foreground "#2aa198"))
;;                     )))
;; (define-key global-map "\C-ca" 'org-agenda)
;; (define-key global-map "\C-cc" 'org-capture)
;; ;; NOTE: the 2 below have a bug where they only do half at a time so
;; ;; it takes YOU, the USER, log(n) time instead of constant time.
;; ;; see http://stackoverflow.com/questions/6997387
;; (defun my-org-archive-done-tasks ()
;;   (interactive)
;;   (org-map-entries 'org-archive-subtree "/DONE" 'file))
;; (defun my-org-archive-cancelled-tasks ()
;;   (interactive)
;;   (org-map-entries 'org-archive-subtree "/CANCELLED" 'file))


;; (require 'org-install)

;; (require 'org-habit)

;; (getcals)
;; (setq org-agenda-include-diary t)
;;;;;;;;;; ;;;;;;;;;; 




(defun sudo-edit (&optional arg)
  "Edit currently visited file as root.

With a prefix ARG prompt for a file to visit.
Will also prompt for a file to visit if current
buffer is not visiting a file."
  (interactive "P")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:"
                         (ido-read-file-name "Find file(as root): ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))



;;;;;;;;;; VI. Lisp & Scheme ;;;;;;;;;;
(add-hook 'scheme-mode-hook 'paredit-mode)
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)
(add-hook 'emacs-lisp-mode-hook 'rainbow-mode)
(add-hook 'css-mode-hook 'rainbow-mode)

;;;;;;;;;; ;;;;;;;;;;

;; ;; Exclude very large buffers from dabbrev
;; (defun sanityinc/dabbrev-friend-buffer (other-buffer)
;;   (< (buffer-size other-buffer) (* 1 1024 1024)))
;; (setq dabbrev-friend-buffer-function 'sanityinc/dabbrev-friend-buffer)
;; (company-mode)

;;;;;;;;;; VII. Shortcuts ;;;;;;;;;;
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
;;;;;;;;;; ;;;;;;;;;;

;;;;;;;;;; VIII. Line Behaviors ;;;;;;;;;;
;; desired default behaviors for lines & line breaks, visually & behind-the-scenes

(global-visual-line-mode 1)
(auto-fill-mode nil)
(remove-hook 'textt-mode-hook 'turn-on-auto-fill)
(global-linum-mode t)
;;;;;;;;;; ;;;;;;;;;;

;;;;;;;;;; IX. Text Mode ;;;;;;;;;;

;;;;;;;;;; ;;;;;;;;;;

(require 'ox-latex)
(unless (boundp 'org-latex-classes)
  (setq org-latex-classes nil))
(add-to-list 'org-latex-classes
             '("article"
               "\\documentclass{article}"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
	       ))


(setq magit-last-seen-setup-instructions "2.4.1")


;;;;;;;;;; X. Remove annoying defaults, provide encouragement ;;;;;;;;;;
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
;;;;;;;;;; END ;;;;;;;;;;

;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(background-color "#002b36")
;;  '(background-mode dark)
;;  '(cursor-color "#839496")
;;  '(custom-enabled-themes (quote (sanityinc-solarized-dark)))
;;  '(custom-safe-themes
;;    (quote
;;     ("4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" default)))
;;  '(foreground-color "#839496")
;;  '(package-selected-packages
;;    (quote
;;     (color-theme-sanityinc-solarized mmm-mode php-mode flx-ido bundler inf-ruby web-mode projectile projectile-rails robe zencoding-mode yaml-mode unfill undo-tree unbound textmate telepathy tabbar switch-window sudo-edit smart-cursor-color slim-mode scss-mode rvm ruby-end ruby-electric rinari rhtml-mode regex-tool rainbow-mode rainbow-delimiters pretty-mode pretty-lambdada pkg-info php+-mode paredit org-mobile-sync org-agenda-property nyan-mode notify noflet mwe-log-commands multicolumn multi-term magit log4e idle-highlight-mode highline highlight-tail goto-chg gntp gnome-calendar flymake-ruby flymake-haml feature-mode dired-details crontab-mode color-theme-solarized coffee-mode closure-template-html-mode auto-complete anything-exuberant-ctags android-mode ace-jump-mode)))
;;  '(projectile-rails-global-mode t))
;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ispell-dictionary nil)
 '(package-selected-packages
   '(paredit cl-libify projectile flx-ido yaml-mode with-editor undo-tree unbound rinari rhtml-mode rainbow-delimiters pretty-lambdada popup php+-mode org-publish-agenda notify mwe-log-commands idle-highlight-mode highline highlight-tail flymake-ruby dired-details color-theme-solarized closure-template-html-mode anything-exuberant-ctags)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
