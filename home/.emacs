;; it's clara's .emacs

;;;;;;;;;; I. Package Management ;;;;;;;;;;
(require 'package)

(add-to-list 'package-archives
             '("ELPA" . "http://tromey.com/elpa/")) 
(add-to-list 'package-archives
               '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/"))
;;(add-to-list 'package-archives
;;               '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives
               '("org" . "http://orgmode.org/elpa/"))
(package-initialize)
(add-to-list 'load-path "~/.emacs.d/")
(add-to-list 'custom-theme-load-path "~/.emacs.d/emacs-color-theme-solarized/")
(add-to-list 'load-path "~/.emacs.d/org-sync")
 (mapc 'load
       '("os" "os-github"))
(setq os-github-auth '("clararaubertas" . "poppyasm"))
(require 'org-agenda-property)
(require 'android-mode)
;; (custom-set-variables '(android-mode-sdk-dir "~/opt/android"))

;; all packages
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
(package-update-all)
(byte-recompile-directory (expand-file-name "~/.emacs.d") 0)
;;;;;;;;;; END Package Management ;;;;;;;;;;

;;;;;;;;;; II. Starter Kit ;;;;;;;;;;
(require 'starter-kit)
;;;;;;;;;; ;;;;;;;;;;

;;;;;;;;;; III. COLORS!!!!! ;;;;;;;;;;
(require 'rainbow-delimiters )


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

;; ;; git
;; (require 'magit)

;; (require 'auto-complete)
;; (require 'auto-complete-config)
;; (global-auto-complete-mode t)
;; (setq ac-expand-on-auto-complete nil)
;; (setq ac-auto-start nil)
;; (setq ac-dwim nil) ; To get pop-ups with docs even if a word is uniquely completed
;; (define-key ac-completing-map (kbd "C-n") 'ac-next)
;; (define-key ac-completing-map (kbd "C-p") 'ac-previous)

;; (require 'ido)
;; (ido-mode t)
;; (setq ido-enable-flex-matching t)

;; buffrs
;; set up ibuffer
;; (autoload 'ibuffer "ibuffer" "List buffers." t)
;; (setq ibuffer-default-sorting-mode 'major-mode)

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
(require 'ruby-electric)
(defun ruby-insert-end () 
  "Insert \"end\" at point and reindent current line." 
  (interactive) 
  (insert "end") 
  (ruby-indent-line t) 
  (end-of-line))

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
(add-to-list 'auto-mode-alist '("\\.cl$" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gem\\(spec\\)?$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))

(add-hook 'ruby-mode-hook '(lambda ()
                               (setq ruby-deep-arglist t)
                               (setq ruby-deep-indent-paren nil)
                               (global-rinari-mode)
                               (esk-paredit-nonlisp)
                               (ruby-electric-mode)
                               (rspec-mode)
                               (rubocop-mode)
                               (ruby-tools-mode)
                               (local-set-key [S-f7] 'ruby-compilation-this-buffer)
                               (define-key ruby-mode-map (kbd "RET") 'reindent-then-newline-and-indent)
                               (define-key ruby-mode-map (kbd "TAB") 'indent-for-tab-command)
                               (local-set-key [f7] 'ruby-compilation-this-test)
                               (local-set-key [f6] 'recompile)
                               (local-set-key (kbd "C-c .") 'rsense-complete)
                               (add-to-list 'ac-sources 'ac-source-rsense-method)
                               (add-to-list 'ac-sources 'ac-source-rsense-constant)
                               ))
(projectile-global-mode)
;;;;;;;;;; end RUBY section ;;;;;;;;;;

;; (setq tab-always-indent 'complete)  ;; use 't when auto-complete is disabled
;; (add-to-list 'completion-styles 'initials t)

;; ;; hook AC into completion-at-point
;; (defun set-auto-complete-as-completion-at-point-function ()
;;   (setq completion-at-point-functions '(auto-complete)))
;; (add-hook 'auto-complete-mode-hook 'set-auto-complete-as-completion-at-point-function)
;; (set-default 'ac-sources
;;              '(ac-source-dictionary
;;                ac-source-words-in-buffer
;;                ac-source-words-in-same-mode-buffers
;;                ac-source-words-in-all-buffer))

;; (dolist (mode '(magit-log-edit-mode log-edit-mode org-mode text-mode haml-mode
;;                 sass-mode yaml-mode csv-mode espresso-mode haskell-mode
;;                 html-mode nxml-mode sh-mode smarty-mode clojure-mode
;;                 lisp-mode textile-mode markdown-mode tuareg-mode
;;                 ruby-mode
;;                 js3-mode css-mode less-css-mode sql-mode))
;;   (add-to-list 'ac-modes mode))


;;;;;;;;;; V. ORG MODE ;;;;;;;;;;
(setq-default major-mode 'org-mode)
(setq org-startup-indented t)

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "|" "DONE(d!)")
              (sequence "WAITING(w)" "SOMEDAY/MAYBE(m)" "JESSE(j)" "PROJECT(p)" "|" "CANCELLED(c)")
)))
(setq org-todo-keyword-faces      (quote (
                    ("TODO" ( :background "#859900" :weight bold :foreground "#002b36"))
                    ("WAITING" (  :weight bold :foreground "#fdf6e3"))
                    ("SOMEDAY/MAYBE" (  :weight bold :foreground "#2aa198"))
                    ("DONE" (  :weight bold :foreground "#859900"))
                    ("PROJECT" ( :background "#2aa198" :weight bold  :foreground "#002b36"))
                    ("JESSE" ( :weight bold :foreground "#fdf6e3"))
                    ("CANCELLED" (  :weight bold :foreground "#2aa198"))
                    )))
(define-key global-map "\C-ca" 'org-agenda)
(define-key global-map "\C-cc" 'org-capture)
;; NOTE: the 2 below have a bug where they only do half at a time so
;; it takes YOU, the USER, log(n) time instead of constant time.
;; see http://stackoverflow.com/questions/6997387
(defun my-org-archive-done-tasks ()
  (interactive)
  (org-map-entries 'org-archive-subtree "/DONE" 'file))
(defun my-org-archive-cancelled-tasks ()
  (interactive)
  (org-map-entries 'org-archive-subtree "/CANCELLED" 'file))

(require 'org-habit)



(setq org-directory "~/Text/")
(setq org-default-notes-file (concat org-directory "/notes.org"))
(setq org-mobile-directory "~/Dropbox/MobileOrg")
(setq org-mobile-inbox-for-pull "~/Text/orgmob")
(setq org-agenda-files (quote ("~/Text/life.org" "~/Text/para" "~/Text/shopping.org" "~/Text/bi.org" "~/Text/movie-diary" "~/Text/books.org" "~/Text/read.org" "~/Text/movies.org" "~/Text/tv.org")))

(setq org-refile-targets '((org-agenda-files :maxlevel . 2)))

(defun my-org-mob-sync()
  (interactive)
              (message "pulling from mobile! ...")
              (org-mobile-pull)
              (message "... pulled from mobile!")

           (message "pushing to mobile! ...")
              (org-mobile-push)
              (message "... pushed to mobile!")
)
(global-set-key '[f4]  'my-org-mob-sync)

(org-mobile-pull) ;; run org-mobile-pull at startup

(defun install-pull-monitor (file secs)
  (run-with-timer
   0 secs
   (lambda (f p)
     (unless (< p (second (time-since (elt (file-attributes f) 5))))
       (org-mobile-pull)
       (org-mobile-push)))
   file secs))

(defun install-push-monitor (file secs)
  (run-with-timer
   0 secs
   (lambda (f p)
     (unless (< p (second (time-since (elt (file-attributes f) 5))))
       (org-mobile-push)))
   file secs))

(install-pull-monitor (file-truename
                  (concat
                   (file-name-as-directory org-mobile-directory)
                          org-mobile-capture-file))
                 5)

(install-push-monitor (file-truename
                  (concat
                   (file-name-as-directory org-directory)
                          "life.org"))
                 5)

;; Do a pull every 5 minutes to circumvent problems with timestamping
;; (ie. dropbox bugs)
(run-with-timer 0 (* 5 60) 'org-mobile-pull)


(add-hook 'org-agenda-mode-hook
          (lambda ()
            (visual-line-mode -1)
            (toggle-truncate-lines 1)))

(setq org-agenda-property-list '("BECAUSE" "LASTCONTACT"))
(setq org-agenda-property-position 'next-line)


(setq enable-recursive-minibuffers t)

(defun org-completing-read (&rest args)
  "Completing-read with SPACE being a normal character."
  (let ((minibuffer-local-completion-map
         (copy-keymap minibuffer-local-completion-map)))
    (org-defkey minibuffer-local-completion-map " " 'self-insert-command)
    (org-defkey minibuffer-local-completion-map "?" 'self-insert-command)
    (org-defkey minibuffer-local-completion-map "!" 'org-time-stamp-inactive)
    (apply 'org-icompleting-read args)))

(setq org-agenda-sorting-strategy '(time-up tag-up priority-down))
(setq org-agenda-include-all-todo t)
(setq org-mobile-agendas '("p"))
(setq org-habit-show-habits-only-for-today t)
(setq org-agenda-span 2)
(setq org-agenda-sticky nil)
(setq org-agenda-show-log t)
(setq org-agenda-skip-scheduled-if-done t)
(setq org-agenda-skip-deadline-if-done t)
(setq  org-habit-show-all-today nil)
(setq org-agenda-todo-ignore-scheduled 'future)
(setq org-agenda-tags-todo-honor-ignore-options t)
(setq org-agenda-custom-commands
      '(
        ;; wow such agenda
        ("p" "wow such agenda"
         ( (tags-todo "+PRIORITY=\"A\""
                      ( (org-agenda-overriding-header "")
                        (org-agenda-sorting-strategy '(todo-state-down tag-up))
                        ))
           (agenda "" 
                   ((org-agenda-ndays 1)                      ;; daily agenda
                    (org-deadline-warning-days 7)             ;; 7 day advanced warning for deadlinesrp
                    ))
           (tags-todo  "+TODO=\"TODO\"-STYLE=\"habit\"+PRIORITY=\"\""
                       ( (org-agenda-overriding-header "")
                         ))
           (tags-todo "-TODO=\"WAITING\"+PRIORITY=\"B\""
                      ( (org-agenda-overriding-header "")
                        (org-agenda-sorting-strategy '(todo-state-down tag-down))
                        ))
           (todo "WAITING"
                 ( (org-agenda-overriding-header nil)
                   ) )
           (tags-todo "+PRIORITY=\"C\""
                      ( (org-agenda-overriding-header nil)
                        (org-agenda-sorting-strategy '(tag-up))
                        ))
           )
         ((org-agenda-compact-blocks t)
          (org-agenda-sorting-strategy '(priority-down time-up tag-down habit-down))
          (org-agenda-prefix-format "  ")
          (org-agenda-skip-entry-if 'scheduled)
          (org-fast-tag-selection-single-key (quote expert))
          (org-habit-following-days 5)
          (org-habit-preceding-days 10)
          (org-agenda-time-grid nil)
          )
         )      
        
        ;; wow such home tasks
        ("h" "wow such home tasks"
         ((tags-todo "home"))
         ((org-agenda-sorting-strategy '(time-up todo-state-up priority-down)))         
         )
        ;; wow such today
        ("d" "wow such today"
         ((agenda "" ((org-agenda-ndays 1)                      ;; daily agenda
                      (org-deadline-warning-days 7)             ;; 7 day advanced warning for deadlines
                      (org-agenda-scheduled-leaders '("" ""))
                      ))
          (todo "TODO"
                (
                 (org-agenda-todo-ignore-scheduled t)
                 (org-agenda-sorting-strategy '(priority-down tag-down))
                 ) )

          (todo "JESSE"               
                ((org-agenda-todo-keyword-format "%-8s "))) 
          )
         ) 
        ;; very context
        ("l" "very context"      
         ((agenda "week upcoming" ((org-agenda-ndays 7)                      ;; overview of appointments
                      (org-agenda-start-on-weekday nil)         ;; calendar begins today
                      (org-agenda-repeating-timestamp-show-all t)
                      (org-agenda-entry-types '(:timestamp :sexp))
                      (org-agenda-time-grid nil)
                      (org-agenda-use-time-grid nil)
                      ))
          ;; today's accomplishments
          (agenda "done today" (
                      (org-agenda-ndays 1)
                      (org-agenda-log-items '(closed state))
                      (org-agenda-repeating-timestamp-show-all t)
                      (org-agenda-show-log t)
                      (org-agenda-todo-keyword-format "")
                      (org-agenda-remove-tags t)
                      (org-agenda-entry-types '(:timestamp))
                      (org-agenda-time-grid nil)
                      (org-agenda-show-diary nil)
                      ))

          (todo "WAITING"
                ((org-agenda-todo-keyword-format "%-8s "))) 
          )

         )

))

(add-hook 'org-agenda-mode-hook
          ;; Always hilight the current agenda line
          '(lambda () (hl-line-mode 1))
          'append)

;; We gonna log stuff here.
(setq org-log-repeat 'time)
;; DONT LOG ORG-MODE-DONE IT FUX U
(setq org-log-done nil)

(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/Text/life.org" "Everys Thang")
             "* TODO %? %i %^g")
        ("j" "Jesse" entry (file+headline "~/Text/life.org" "Everys Thang")
             "* JESSE %? %i %^g")
        ("s" "Shopping" entry (file+headline "~/Text/shopping.org" "Buy It")
             "* %? %i %^g")

  ("q" "Quick task" entry
         (file+headline "~/personal/organizer.org" "Tasks")
         "* TODO %^{Task}
SCHEDULED: %^t"
         :immediate-finish t)
))


(set-face-attribute 'org-agenda-date nil :background "#073642"  :foreground "#859900" :underline t)
(set-face-attribute 'org-agenda-date-weekend nil :foreground "#859900" :background "#073642" :underline t)
(set-face-attribute 'org-agenda-date-today nil :background "#262626")
(set-face-attribute 'org-agenda-diary nil :foreground "#fdf6e3" )
(set-face-attribute 'org-agenda-done nil :foreground "#93a1a1"  :strike-through t)
(set-face-attribute 'org-done nil :strike-through t  )

(set-face-attribute 'org-habit-alert-face nil :background "#b58900" :bold t :strike-through nil :foreground "#073652")
(set-face-attribute 'org-habit-alert-future-face nil :background "#268bd2" :strike-through nil :foreground "#073642")
(set-face-attribute 'org-habit-clear-face nil :background "#073642"  :strike-through nil)
(set-face-attribute 'org-habit-clear-future-face nil :background "#6c71c4" )
(set-face-attribute 'org-habit-overdue-face nil :background "#d33682" :bold t :strike-through nil :foreground "#fdf6e3")
(set-face-attribute 'org-habit-overdue-future-face nil :background "#657b83" :strike-through nil :underline nil)
(set-face-attribute 'org-habit-ready-face nil :background "#fdf6e3" :foreground "#657b83")
(set-face-attribute 'org-habit-ready-future-face nil :background "#073642")
(set-face-attribute 'org-habit-warning-face nil :background: "#b58900")
(setq org-habit-graph-column 35)

(set-face-attribute 'org-scheduled-previously nil :foreground "#b58900" :bold t :background "#073642")
(set-face-attribute 'org-scheduled-today nil :background "#073642"  :foreground "#fdf6e3")
(set-face-attribute 'org-upcoming-deadline nil :foreground "#b85990"  )
(set-face-attribute 'org-warning nil :foreground "#b58900"  )



(defun org-todo-toggle-yesterday ()
  ;; this function is interactive, meaning a "command" that we call
  ;; as an emacs user (allows us to do "M-x org-todo-toggle-yesterday")
  (interactive)

  (let ((time-in-question (decode-time))) 
    ;; time-in-question is the current time, decoded into convenient fields

    ;; decrease the field by one which represents the day -- make it "yesterday"
    (decf (nth 3 time-in-question))

    ;; now, re-encode that time
    (setq time-in-question (apply 'encode-time time-in-question))

    (cl-flet ((current-time () time-in-question))
      ;; flet temporarily binds current-time to this version, which
      ;; returns the time from yesterday 

      (org-todo)
      ;; toggles the todo heading
      )))

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
;;;;;;;;;; ;;;;;;;;;; 

;;;;;;;;;; VI. Lisp & Scheme ;;;;;;;;;;
(add-hook 'scheme-mode-hook 'paredit-mode)
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)
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
(global-hl-line-mode 1)
(global-visual-line-mode 1)
(auto-fill-mode nil)
(remove-hook 'text-mode-hook 'turn-on-auto-fill)
(global-linum-mode t)
;;;;;;;;;; ;;;;;;;;;;

;;;;;;;;;; IX. Text Mode ;;;;;;;;;;
(add-hook 'text-mode-hook 'flyspell-mode)
;;;;;;;;;; ;;;;;;;;;;

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

