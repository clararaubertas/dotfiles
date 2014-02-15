;; it's clara's .emacs

;; get everything ready to load
(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)
(add-to-list 'load-path "~/.emacs.d/")
(add-to-list 'load-path "~/icicles/")
(add-to-list 'custom-theme-load-path "~/.emacs.d/emacs-color-theme-solarized/")

(require 'starter-kit)

;; modez
(setq-default major-mode 'org-mode)
(setq org-startup-indented t)
(setq transient-mark-mode t)
(fset 'yes-or-no-p 'y-or-n-p)
(global-linum-mode t)
(add-hook 'scheme-mode-hook 'paredit-mode)
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)

;; colors!!
(require 'rainbow-delimiters )
(require 'rainbow-mode)
(require 'pretty-mode)
(global-font-lock-mode t)
(add-hook 'css-mode-hook (lambda () (rainbow-mode 1)))
(add-hook 'ruby-mode-hook (lambda () (rainbow-mode 1)))
(add-hook 'emacs-lisp-mode-hook (lambda () (rainbow-mode 1)))
(global-rainbow-delimiters-mode)
(global-pretty-mode)
(load-theme 'solarized-dark t)
(set-face-foreground 'default "#fdf6e3") ; Normal
(set-face-foreground 'mode-line "#859900")
(set-face-foreground 'mode-line-inactive "#2aa198")
(setq default-frame-alist
      '((background-color . "#002b36")))
(defvar blink-cursor-colors (list "#b58900" "#859900" "#268bd2")
  "On each blink the cursor will cycle to the next color in this list.")
(setq blink-cursor-count 0)
(defun blink-cursor-timer-function ()
  "Zarza wrote this cyberpunk variant of timer `blink-cursor-timer'. 
This one changes the cursor color on each blink. Define colors in `blink-cursor-colors'."
  (when (not (internal-show-cursor-p))
    (when (>= blink-cursor-count (length blink-cursor-colors))
      (setq blink-cursor-count 0))
    (set-cursor-color (nth blink-cursor-count blink-cursor-colors))
    (setq blink-cursor-count (+ 1 blink-cursor-count))
    )
  (internal-show-cursor nil (not (internal-show-cursor-p)))
  )
(add-to-list 'default-frame-alist '(cursor-color . "#859900"))
;; cursor
(require 'cursor-chg)  ; Load the library
(toggle-cursor-type-when-idle 1) ; Turn on cursor change when Emacs is idle
(change-cursor-mode 1) ; Turn on change for overwrite, read-only, and input mode


;; who needs this crap!
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(setq inhibit-startup-screen t)   
(setq inhibit-splash-screen t)


;; Put autosave files (ie #foo#) and backup files (ie foo~) in ~/.emacs.d/.
(custom-set-variables
  '(auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t)))
  '(backup-directory-alist '((".*" . "~/.emacs.d/backups/"))))
;; create the autosave dir if necessary, since emacs won't.
(make-directory "~/.emacs.d/autosaves/" t)

;; When saving files, set execute permission if #! is in first line.
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;; git
(require 'magit)


(require 'auto-complete)
(require 'auto-complete-config)
(global-auto-complete-mode t)
(setq ac-expand-on-auto-complete nil)
(setq ac-auto-start nil)
(setq ac-dwim nil) ; To get pop-ups with docs even if a word is uniquely completed
(define-key ac-completing-map (kbd "C-n") 'ac-next)
(define-key ac-completing-map (kbd "C-p") 'ac-previous)

(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t)

;; buffrs
;; set up ibuffer
(autoload 'ibuffer "ibuffer" "List buffers." t)
(setq ibuffer-default-sorting-mode 'major-mode)

;; uniquify
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)
;; Remap common buffer bindings to ibuffer and iswitchb

(define-key global-map "\C-x\C-b" 'ibuffer-other-window)

;; RUBY
;; rb basics
;; Rsense
(setq rsense-home "/opt/rsense-0.3")
(add-to-list 'load-path (concat rsense-home "/etc"))
(require 'rsense)
(add-to-list 'load-path "~/.emacs.d/rinari")
(require 'rinari)
(require 'ruby-electric)
;; rb modes
(require 'yaml-mode)
(add-to-list 'load-path "~/.emacs.d/rhtml-minor-mode")
(require 'rhtml-mode)
(add-to-list 'interpreter-mode-alist '("ruby" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.r\\(b\\(w\\|x\\)?\\|html?\\|js\\)$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\([Rr]ake\\|[Cc]ap\\|[Gg]em\\)file$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.cl$" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gem\\(spec\\)?$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(require 'ruby-compilation-rspec)
(setq flymake-gui-warnings-enabled nil)
;; hoooks
(add-hook 'ruby-mode-hook '(lambda ()
                               (setq ruby-deep-arglist t)
                               (setq ruby-deep-indent-paren nil)
                               (global-rinari-mode)
                               (esk-paredit-nonlisp)
                               (ruby-electric-mode)
                               (rspec-mode)
                               (flymake-ruby-load)
                               (local-set-key [S-f7] 'ruby-compilation-this-buffer)
                               (define-key ruby-mode-map (kbd "RET") 'reindent-then-newline-and-indent)
                               (define-key ruby-mode-map (kbd "TAB") 'indent-for-tab-command)
                               (local-set-key [f7] 'ruby-compilation-this-test)
                               (local-set-key [f6] 'recompile)
                               (local-set-key (kbd "C-c .") 'rsense-complete)
                               (add-to-list 'ac-sources 'ac-source-rsense-method)
                               (add-to-list 'ac-sources 'ac-source-rsense-constant)
                               )
          )

(setq tab-always-indent 'complete)  ;; use 't when auto-complete is disabled
(add-to-list 'completion-styles 'initials t)

;; hook AC into completion-at-point
(defun set-auto-complete-as-completion-at-point-function ()
  (setq completion-at-point-functions '(auto-complete)))
(add-hook 'auto-complete-mode-hook 'set-auto-complete-as-completion-at-point-function)
(set-default 'ac-sources
             '(ac-source-dictionary
               ac-source-words-in-buffer
               ac-source-words-in-same-mode-buffers
               ac-source-words-in-all-buffer))

(dolist (mode '(magit-log-edit-mode log-edit-mode org-mode text-mode haml-mode
                sass-mode yaml-mode csv-mode espresso-mode haskell-mode
                html-mode nxml-mode sh-mode smarty-mode clojure-mode
                lisp-mode textile-mode markdown-mode tuareg-mode
                ruby-mode
                js3-mode css-mode less-css-mode sql-mode))
  (add-to-list 'ac-modes mode))

;; Exclude very large buffers from dabbrev
(defun sanityinc/dabbrev-friend-buffer (other-buffer)
  (< (buffer-size other-buffer) (* 1 1024 1024)))
(setq dabbrev-friend-buffer-function 'sanityinc/dabbrev-friend-buffer)
(company-mode)

;; useful shortcuts
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

;; Upgrade all packages
(defun package-update-all ()
  "Update all packages"
  (interactive)
  (dolist (elt package-alist)
    (let* ((name (car elt))
           (file-name (symbol-name name))
           (available-pkg (assq name package-archive-contents))
           (available-version (and available-pkg
                                   (package-desc-vers (cdr available-pkg))))
           (current-version (package-desc-vers (cdr elt)))
           )
      (when (and available-version
                 (version-list-< current-version available-version))
        (message "Updating to: %s - %s" file-name
                 (package-version-join available-version))
        (package-install name)
        (package-delete file-name (package-version-join current-version))))))

;; orgmode
(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)" "NOTNOW(n)")
              (sequence "WAITING(w)" "HOLD(h)" "JESSE(j)" "|" "CANCELLED(c)" "PHONE" "MEETING")
)))
(setq org-todo-keyword-faces      (quote (
                    ("TODO" ( :background "#859900" :weight bold :foreground "#002b36"))
                    ("WAITING" (  :weight bold :foreground "#2aa198"))
                    ("NOTNOW" (  :weight bold :foreground "#2aa198"))
                    ("DONE" (  :weight bold :foreground "#859900"))
                    ("HOLD" ( :background "#2aa198" :weight bold  :foreground "#002b36"))
                    ("JESSE" ( :weight bold :foreground "#fdf6e3"))
                    ("CANCELLED" (  :weight bold :foreground "#2aa198"))
                    )))
(define-key global-map "\C-ca" 'org-agenda)
(define-key global-map "\C-cc" 'org-capture)
(defun lawlist-sort ()
    (interactive)
    (goto-char (point-min))
    (while
    (re-search-forward "^\* " nil t) ;; sorts the whole kitten caboodle
        (goto-char (match-beginning 0))
        (condition-case err
            (progn
                (org-sort-entries t ?a)
                (org-sort-entries t ?o)
                (org-sort-entries t ?p)
                (org-sort-entries t ?t)
                (forward-line))
            (error nil)
        )
    )
    (goto-char (point-min))
    (while
        (re-search-forward "^\* ARCHIVES" nil t)
        (goto-char (match-beginning 0))
        (condition-case err
           (progn
                (org-sort-entries t ?a)
                (org-sort-entries t ?o)
                (org-sort-entries t ?p)
                (forward-line))
        (error nil)
        )
    ) )
(setq org-directory "~/Text/")
(setq org-default-notes-file (concat org-directory "/notes.org"))
(setq org-mobile-directory "~/Dropbox/MobileOrg")
(setq org-mobile-inbox-for-pull "~/Text/orgmob")
(setq org-agenda-files (quote ("~/Text/life.org" "~/Text/para")))
(require 'org-habit)
(setq org-log-done 'time)

(defvar org-mobile-sync-timer nil)
(defvar org-mobile-sync-idle-secs (* 60 5))
(defun org-mobile-background-sync ()
     (start-process 'org-mobile-sync))
(defun org-mobile-sync ()
  (interactive)
  (org-mobile-pull)
  (org-mobile-push))
(defun org-mobile-sync-enable ()
  "enable mobile org idle sync"
  (interactive)
  (setq org-mobile-sync-timer
        (run-with-idle-timer org-mobile-sync-idle-secs t
                             'org-mobile-background-sync)));
(defun org-mobile-sync-disable ()
  "disable mobile org idle sync"
  (interactive)
  (cancel-timer org-mobile-sync-timer))
(org-mobile-sync-enable)

;; Parent can't be marked as done unless all children are done
(setq org-enforce-todo-dependencies t)
(defun org-summary-todo (n-done n-not-done)
  "Switch entry to DONE when all subentries are done, to TODO otherwise."
  (let (org-log-done org-log-states)   ; turn off logging
    (org-todo (if (= n-not-done 0) "DONE" "TODO"))))
(setq org-agenda-custom-commands
      '(("n" "my preferred view"
         ((agenda "" (
                        (org-agenda-ndays 1)
                        (org-agenda-log-mode-items '(closed state))
                        (org-agenda-show-log t)
                        (org-agenda-todo-keyword-format "DONE")
                        (org-agenda-entry-types '(:timestamp))
                        (org-agenda-time-grid nil)
                        (org-agenda-compact-blocks t)))
          ( agenda "" ((org-agenda-ndays 1)
                        (org-agenda-compact-blocks t)))
          (todo "TODO"                                          ;; todos sorted by context
                (
                 (org-agenda-sorting-strategy '(priority-down tag-up))
                 (org-agenda-overriding-header " ")
                 (org-agenda-compact-blocks t)
                 ))
          (todo "JESSE"
                ((org-agenda-compact-blocks t)
                 (org-agenda-overriding-header " ")))
          (todo "WAITING"
                ((org-agenda-compact-blocks t)
                 (org-agenda-overriding-header " ")))
          (todo "HOLD"
                ((org-agenda-compact-blocks t)
                 (org-agenda-overriding-header " ")))
          )
        )
      ))

(add-hook 'org-agenda-mode-hook '(lambda () (hl-line-mode 1)))
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/Text/life.org" "Tasks")
             "* TODO %?\n  %i\n  %a")))
(custom-set-variables
 '(org-agenda-ndays 7)
 '(org-deadline-warning-days 7)
 '(org-agenda-show-all-dates t)
 '(org-agenda-start-on-weekday nil)
 '(org-reverse-note-order t)
  '(org-agenda-todo-ignore-scheduled t)
 '(org-fast-tag-selection-single-key (quote expert))
)
(set-face-attribute 'org-agenda-done nil :foreground "#2aa198"  )
(set-face-attribute 'org-warning nil :foreground "#fdf6e3"  )
(set-face-attribute 'org-scheduled-previously nil :foreground "eee8d5" :bold t )
(set-face-attribute 'org-upcoming-deadline nil :foreground "#859900"  )
(set-face-attribute 'org-scheduled-today nil :foreground "#eee8d5"  )

(setq mark-diary-entries-in-calendar t)
(defun getcal (url)
  "Download ics file and add to diary"
  (let ((tmpfile (url-file-local-copy url)))
    (icalendar-import-file tmpfile "~/diary" t)
    (kill-buffer (car (last (split-string tmpfile "/"))))
    )
  )
(setq google-calendars '(
                         "https://www.google.com/calendar/ical/clara.raubertas%40gmail.com/private-89f852a8af2420a9afcf0b88b36658eb/basic.ics"
                         "https://www.google.com/calendar/ical/qefiaa27cig1mlij5v44e0orfo%40group.calendar.google.com/private-3c956aa9fec9c60483ee639b701d9408/basic.ics"
                         ))
(defun getcals ()
  (find-file "~/diary")
  (flush-lines "^[& ]")
  (dolist (url google-calendars) (getcal url))
  (kill-buffer "diary"))
(getcals)
(setq org-agenda-include-diary t)


(setq debug-on-error nil)
(setq inhibit-startup-echo-area-message "clara") 
(setq initial-scratch-message nil)
(message "You're doing a great job!")
