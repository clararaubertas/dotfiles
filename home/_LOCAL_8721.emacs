;; it's clara's .emacs

;;;;;;;;;; I. Package Management ;;;;;;;;;;

(package-initialize)
(add-to-list 'package-archives
             '("ELPA" . "http://tromey.com/elpa/")) 
(add-to-list 'package-archives
               '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
               '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives
               '("org" . "http://orgmode.org/elpa/"))


(add-to-list 'load-path "~/.emacs.d/*")
(add-to-list 'custom-theme-load-path "~/.emacs.d/emacs-color-theme-solarized/")
(add-to-list 'load-path "~/.emacs.d/org-sync")

(mapc 'load
       '("os" "os-github"))
(setq os-github-auth '("clararaubertas" . "poppyasm"))
(require 'org-agenda-property)
(require 'android-mode)


(projectile-global-mode)

;;;;;;;;;; ;;;;;;;;;;

;;;;;;;;;; III. COLORS!!!!! ;;;;;;;;;;
(set-face-attribute 'default t :font "PT Mono-13" )

 (define-globalized-minor-mode my-global-rainbow-delim-mode rainbow-delimiters-mode
   (lambda () (rainbow-delimiters-mode 1)))
 (my-global-rainbow-delim-mode 1)


 (define-globalized-minor-mode my-global-idle-highlight-mode idle-highlight-mode
   (lambda () (idle-highlight-mode 1)))
 (my-global-idle-highlight-mode 1)

(define-globalized-minor-mode my-global-blink-cursor-mode blink-cursor-mode
  (lambda () (blink-cursor-mode 1)))
(my-global-blink-cursor-mode 1)



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


(setq default-frame-alist
      '((background-color . "#002b36")))



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

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)



;; git
(require 'magit)

;; (require 'auto-complete)
;; (require 'auto-complete-config)
(global-auto-complete-mode t)
;; (setq ac-expand-on-auto-complete nil)
;; (setq ac-auto-start nil)
;; (setq ac-dwim nil) ; To get pop-ups with docs even if a word is uniquely completed
;; (define-key ac-completing-map (kbd "C-n") 'ac-next)
;; (define-key ac-completing-map (kbd "C-p") 'ac-previous)

(require 'ido)
(ido-mode t)
;; (setq ido-enable-flex-matching t)
(allout-mode)

(global-set-key [(control .)] 'goto-last-change)
; M-. can conflict with etags tag search. But C-. can get overwritten
; by flyspell-auto-correct-word. And goto-last-change needs a really
; fast key.
(global-set-key [(meta .)] 'goto-last-change)
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
(add-to-list 'auto-mode-alist '("\\.cl$" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gem\\(spec\\)?$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))

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
                               (add-to-list 'ac-sources 'ac-source-rsense-constant)
                               ))

;;;;;;;;;; end RUBY section ;;;;;;;;;;

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


(require 'org-install)

(require 'org-habit)



(setq org-directory "~/Text/")
(setq org-default-notes-file (concat org-directory "/notes.org"))
(setq org-mobile-directory "~/Dropbox/MobileOrg")
(setq org-mobile-inbox-for-pull "~/Text/orgmob")
(require 'org-mobile-sync)
(org-mobile-sync-mode 1)
(setq org-agenda-files (quote ("~/Text/life.org" "~/Text/shopping.org" "~/Text/movie-diary" "~/Text/books.org" "~/Text/read.org" "~/Text/movies.org")))

(setq org-refile-targets '((org-agenda-files :maxlevel . 2)))

(add-hook 'org-agenda-mode-hook
          (lambda ()
            (visual-line-mode -1)
            (linum-mode -1)
            (toggle-truncate-lines 1)))

;; (setq org-agenda-property-list '("BECAUSE" "LASTCONTACT"))
;; (setq org-agenda-property-position 'next-line)


;;(setq enable-recursive-minibuffers t)

;; (defun org-completing-read (&rest args)
;;   "Completing-read with SPACE being a normal character."
;;   (let ((minibuffer-local-completion-map
;;          (copy-keymap minibuffer-local-completion-map)))
;;     (org-defkey minibuffer-local-completion-map " " 'self-insert-command)
;;     (org-defkey minibuffer-local-completion-map "?" 'self-insert-command)
;;     (org-defkey minibuffer-local-completion-map "!" 'org-time-stamp-inactive)
;;     (apply 'org-icompleting-read args)))

(setq org-agenda-sorting-strategy '(priority-down effort-down tag-up))
(setq org-agenda-include-all-todo t)
(setq org-mobile-agendas '("p"))
(setq org-habit-show-habits-only-for-today t)
(setq org-agenda-span 2)
(setq org-agenda-sticky nil)
(setq org-agenda-show-log t)
(setq org-agenda-skip-scheduled-if-done t)
(setq org-agenda-skip-deadline-if-done t)
(setq org-habit-show-all-today nil)
(setq org-agenda-todo-ignore-scheduled 'future)
(setq org-agenda-tags-todo-honor-ignore-options t)

(setq org-agenda-prefix-format "%-5e %-3s")



(setq org-agenda-custom-commands
      '(
        ;; wow such 
        ("p" "wow such agenda"
         (
	  (tags-todo "-TODO=\"WAITING\"+PRIORITY=\"A\"-STYLE=\"habit\""
		     (
		      (org-agenda-overriding-header " -everys thang:-")
                         (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled 'deadline))
			;;                        (org-agenda-sorting-strategy '(todo-state-down tag-up))
		      )
		     )
	  (agenda "-TODO=\"WAITING\"" 
                   (
		    (org-agenda-overriding-header " -today - ")
		    (org-agenda-ndays 3)                      ;; daily agenda
                    (org-deadline-warning-days 7)             ;; 7 day advanced warning for deadlines
                    ))
	  (tags-todo  "+TODO=\"TODO\"-STYLE=\"habit\"+PRIORITY=\"\""
		      (
		       (org-agenda-overriding-header " -")
		       (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled 'deadline))
		       )
		      ) 
	  (tags-todo "-TODO=\"JESSE\"-TODO=\"WAITING\"+PRIORITY=\"B\"-STYLE=\"habit\""
		     (
		      (org-agenda-overriding-header "")
		      (org-agenda-sorting-strategy '(todo-state-down priority-down tag-down))
                         (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled 'deadline))
		      )
		     )
	  (todo "WAITING"
		(
		 (org-agenda-overriding-header "[WAITING]")
                    (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled 'deadline))
		 )
		)
	  (todo "JESSE"
		( (org-agenda-overriding-header "[JESSE]")
		  ) )
	  (tags-todo "+PRIORITY=\"C\"-STYLE=\"habit\"-TODO=\"WAITING\""
		     (
		      (org-agenda-overriding-header " --- ")  
		      (org-agenda-sorting-strategy '(tag-up))
		      )
		     )		       
	  	   )
	  
	  (
	   (org-agenda-compact-blocks t)
	   (org-agenda-show-inherited-tags nil)
	   (org-agenda-tags-column 70)
	   (org-agenda-skip-entry-if 'scheduled)
	   (org-fast-tag-selection-single-key (quote expert))
	   (org-habit-following-days 8)
	   (org-habit-preceding-days 12) 
	   (org-agenda-todo-keyword-format " + ")
	   (org-agenda-scheduled-leaders '("0d" "%dx"))
	   (org-agenda-deadline-leaders '("0d" "%dd"))
	   (org-agenda-time-grid nil)

	   )
	  )
	 )
	)
      


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

	))

(set-face-attribute 'org-habit-alert-face nil :background "#b58900"
		    :bold t :strike-through nil :foreground "#002b36"
		    )
(set-face-attribute 'org-habit-alert-future-face nil :background
		    "#002b36" :strike-through nil :foreground "#cb4b16"
		    :bold t )
(set-face-attribute 'org-habit-clear-face nil :background "#002b36"
		    :strike-through nil :bold t )
(set-face-attribute 'org-habit-clear-future-face nil :background
		    "#839496" )
(set-face-attribute 'org-habit-overdue-face nil :background "#dc322f"
		    :strike-through nil :foreground
		    "#073642" :bold t )
(set-face-attribute 'org-habit-overdue-future-face nil :background
		    "#073642" :strike-through nil :underline nil
		     )
(set-face-attribute 'org-habit-ready-face nil :background "#eee8d5"
		    :foreground "#002b36" :bold nil 
		    )
(set-face-attribute 'org-habit-ready-future-face nil :background
		    "#586e75" )
(setq org-habit-show-done-always-green t)
(setq org-habit-today-glyph ?!)
(setq org-habit-completed-glyph ?+)

(add-hook 'org-finalize-agenda-hook
          (lambda ()  (setq line-spacing '0.1)))

(setq org-habit-graph-column 45)
(setq line-spacing '0.1)

(setq org-agenda-deadline-faces
      '((1.0 . (:foreground "#d33682"))
	(0.7 . (:foreground "#b58900"))
	(0.0 . (:foreground "#268bd2"))
	))
(setq org-priority-faces
      '(( ?A . (:foreground "#dc322f" :weight demibold :family "Accanthis ADF Std" :height .9))
	( ?B . ( :foreground "#b58900" :weight demibold :family "Accanthis ADF Std" :height .9))
	( ?C . ( :foreground "#eee8d5":weight demibold :family "Accanthis ADF Std" :height .9))
	))
(setq org-tag-faces
      '(
	("home" . (:inherit org-tag :foreground "#eee8d5" :weight demibold))
	("computer" . (:inherit org-tag :foreground "#859900" :weight demibold))
	("bedroom" . "#586e75")
	("kitchen" . "#8394a6")
	("diningroom" . "#93a1a1")
	("frontroom" . "#657b83")
	("office" .  "#586e75")
	("malka".  "#fdf6e3")
	("hp" .  (:inherit org-tag :foreground  "#b58900" :weight black))
	("phone" .  "#d33682")
	("para". "#268bd2")
	("bathroom" .  "#93a1a1")
	))

(custom-set-faces
 '(org-agenda-date ((t (:weight semi-bold :height 1.2 :background "#073642" :foreground "#fdf6e3" :italic nil))) t)
 '(org-agenda-structure ((t (:weight normal :height 1.5 :background "#002b36" :foreground "#eee8d5"   :italic true :underline nil :weight semibold))) t)
 '(org-agenda-date ((t (:weight normal :height 1.1 :background "#002b36" :foreground "#eee8d5"   :italic true :underline t))) t)
 '(org-agenda-date-today ((t (:inherit org-agenda-date :height 1.2 :italic t   :foreground "#002b36" :background "#eee8d5" ))))
 '(org-scheduled-previously ((t (:foreground "#dc322f" :weight bold))))
'(org-done ((t (:foreground "gray57" :weight light))))
'(org-level-1 ((t (:weight semi-bold :height 1.1 ))))
'(org-level-2 ((t (:inherit outline-2 :weight semi-bold :height 1.1 :family "Accanthis ADF Std "))))
'(org-warning-2 ((t (:inherit outline-2 :weight semi-bold :height 1.1 :foreground "#b58900"))))
'(org-level-3 ((t (:inherit outline-3 :weight bold))))
'(org-upcoming-deadline ((t (:inherit outline-3 :weight semi-bold))))
'(org-level-5 ((t (:inherit outline-5 :family ))))
'(org-link ((t (:inherit link :weight normal))))
'(org-scheduled-today ((t (:foreground "#fdf6e3" :weight semi-bold ))))
  '(org-scheduled ((t (:foreground "#fdf6e3" :weight bold ))))
'(org-meta-line ((t (:inherit font-lock-comment-face :height 0.8))))
'(org-property-value ((t (:height 0.9 ))) t)
'(org-special-keyword ((t (:inherit font-lock-keyword-face :height 0.8))))
'(org-table ((t (:foreground "dim gray" :height 0.9 ))))
'(org-tag ((t (:foreground "#eee8d5" :weight normal :italic t :overline nil :height 0.95   :width expanded))))
'(org-todo ((t (:weight bold)))))

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

;; (setq mark-diary-entries-in-calendar t)
;; (defun getcal (url)
;;   "Download ics file and add to diary"
;;   (let ((tmpfile (url-file-local-copy url)))
;;     (icalendar-import-file tmpfile "~/diary" t)
;;     (kill-buffer (car (last (split-string tmpfile "/"))))
;;     )
;;   )
;; (setq google-calendars '(
;;                      "https://www.google.com/calendar/ical/clara.raubertas%40gmail.com/private-89f852a8af2420a9afcf0b88b36658eb/basic.ics"
;;                          "https://www.google.com/calendar/ical/qefiaa27cig1mlij5v44e0orfo%40group.calendar.google.com/private-3c956aa9fec9c60483ee639b701d9408/basic.ics"
;;                          ))
;; (defun getcals ()
;;   (find-file "~/diary")
;;   (flush-lines "^[& ]")
;;   (dolist (url google-calendars) (getcal url))
;;   (kill-buffer "diary"))
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
(remove-hook 'text-mode-hook 'turn-on-auto-fill)
(global-linum-mode t)
;;;;;;;;;; ;;;;;;;;;;

;;;;;;;;;; IX. Text Mode ;;;;;;;;;;
(add-hook 'text-mode-hook 'flyspell-mode)
;;;;;;;;;; ;;;;;;;;;;

(setq magit-last-seen-setup-instructions "1.4.0")


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

