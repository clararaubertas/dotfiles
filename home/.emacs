;; it's clara's .emacs

;;;;;;;;;; I. Package Management ;;;;;;;;;;

(package-initialize)
(require 'org)
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
;; (add-to-list 'custom-theme-load-path "~/.emacs.d/emacs-color-theme-solarized/")

(add-to-list 'load-path "~/.emacs.d/org-sync")

(load "~/.emacs.d/filenotify.el")


(setq solarized-use-variable-pitch nil)

(setq tex-command "pdflatex")
(defun tex-view ()
  (interactive)
  (tex-send-command "evince" (tex-append tex-print-file ".pdf")))

(mapc 'load
      '("os" "os-github"))
(setq os-github-auth '("clararaubertas" . "poppyasm"))
(require 'org-agenda-property)
(require 'android-mode)
(setq android-mode-builder 'gradle)


(defun android-tool-path (name)
  (concat "/home/clara/android-sdk-linux/tools/" name)
  )


(projectile-global-mode)

;;;;;;;;;; ;;;;;;;;;;

;;;;;;;;;; III. COLORS!!!!! ;;;;;;;;;;
(set-frame-font "Input Mono Light-14" )


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


(load-theme 'solarized-light t)
(set-face-foreground 'default "#002b36") ; Normal
                                        ; (set-face-foreground 'mode-line "#859900")
                                        ; (set-face-foreground 'mode-line-inactive "#2aa198")
                                        ; (set-face-background 'highlight "#073642")
                                        ; (set-face-foreground 'highlight nil)
                                        ; (set-face-background 'idle-highlight "#859900")
                                        ; (set-face-foreground 'idle-highlight nil)
(setq default-frame-alist
      '((background-color . "#fdf6e3")))

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

;; some fun stuff
(require 'zone)
;;(setq zone-programs [zone-pgm-rotate])
(setq zone-programs [zone-pgm-putz-with-case zone-pgm-drip-fretfully zone-pgm-random-life])
(zone-when-idle 120)
(highlight-tail-mode)
;;(require 'smooth-scrolling)


;; some modeline stuff
(set-face-attribute 'mode-line nil :font "Input Mono Light-12")
(setq nyan-bar-length 12)
(nyan-mode)

(set-face-background 'mode-line "#073642")
(set-face-foreground 'mode-line "#eee8d5")

(defun shorten-directory (dir max-length)
  "Show up to `max-length' characters of a directory name `dir'."
  (let ((path (reverse (split-string (abbreviate-file-name dir) "/")))
        (output ""))
    (when (and path (equal "" (car path)))
      (setq path (cdr path)))
    (while (and path (< (length output) (- max-length 4)))
      (setq output (concat (car path) "/" output))
      (setq path (cdr path)))
    (when path
      (setq output (concat "…/" output)))
    output))

(defun shorten-modes (modelist max-length)
  "Show up to `max-length' characters of a mode list `modelist'."
  (let ((path (reverse (split-string modelist " ")))
        (output ""))
    (when (and path (equal "" (car path)))
      (setq path (cdr path)))
    (while (and path (< (length output) (- max-length 4)))
      (setq output (concat (car path) " " output))
      (setq path (cdr path)))
    (when path
      (setq output (concat "…" output "…")))
    output))

(require 'battery)
(defun battery-level ()
  (string-to-number (shell-command-to-string "echo \"$(acpi | perl -pe 's/.*?,//' | perl -pe 's/%//')
\"")))

(defvar battery-status-function 'battery-level)


(setq-default mode-line-format
	      '("%e"
                (:eval
                 (let* (
                        (bat (funcall 'battery-level))
                        (index (cl-position-if (lambda (e) (> bat e)) '(87 75 62 50 37 25 12 7 -1)))
                        (str (nth index '(" █ " " ▇ " " ▆ " " ▅ " " ▄ " " ▃ " " ▂ " " ▁ " " ! ")))
                        (color (nth index '("#859900" "#909900" "#aa9900" "#b09000" "#b58900" "#c17a23" "#c96841" "#cb4b16" "#dc322f")))
                        )
                   (propertize str 'face (list :foreground color :box (if (<= bat 7) color nil)))
                   )
                 )
                
		(:eval (if (buffer-modified-p)
			   (propertize "⚠" 'face 'error)
                          " "
                         )
                       )
                (:eval (if buffer-read-only
			   (propertize "✘" 'face 'error)
                          " "
                           ))
                " "
                (:propertize (:eval (shorten-directory default-directory 20) )
                             face (:foreground "#268bd2" :weight bold))
                (:propertize "%b"
                             face (:foreground "#859900" :weight bold))
		(:propertize (vc-mode vc-mode)
                             face (:foreground "#2aa198" )) 
                " %n "
                "%I"
                (:eval (when nyan-mode (list (nyan-create))))
                "| "
                (:propertize mode-name
                             face (:foreground "#b58900"))
                " "
                (:propertize (:eval (shorten-modes (format-mode-line minor-mode-alist) 20 ) ) 
                             face (:foreground "#6c71c4"))
                " "
                (:eval (format-time-string "%a %b %d %H:%M")) 
		mode-line-misc-info

                ))


(setq weather-metno-location-name "Chicago, IL"
      weather-metno-location-latitude 41
      weather-metno-location-longitude 87
      weather-metno-format "{symbol|:symbol}  {temperature-min}–{temperature-max} ℃ ({temperature-min-time|:time}–{temperature-max-time|:time}) {precipitation-min}–{precipitation-max} ㎜ ({precipitation-min-time|:time}–{precipitation-max-time|:time})"
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

 (global-set-key (kbd "M-x") 'smex)
 (global-set-key (kbd "M-X") 'smex-major-mode-commands)
 ;; This is your old M-x.
 (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)



;; git
;;(require 'magit)

;; (require 'auto-complete)
;; (require 'auto-complete-config)
(global-auto-complete-mode t)
;; (setq ac-expand-on-auto-complete nil)
;; (setq ac-auto-start nil)
;; (setq ac-dwim nil) ; To get pop-ups with docs even if a word is uniquely completed
;; (define-key ac-completing-map (kbd "C-n") 'ac-next)
;; (define-key ac-completing-map (kbd "C-p") 'ac-previous)

(require 'ido)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)
;; (allout-mode)

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

(setq org-bullets-bullet-list
      '("◉" "◎" "￼" "○" "►" "◇"))
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

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


(add-to-list 'org-modules 'org-habit)





(setq org-directory "~/Text/")
(setq org-default-notes-file (concat org-directory "/notes.org"))

(setq org-mobile-directory "/pepper.parallactic.com:MobileOrg")
(setq tramp-terminal-type "dumb")
(setq org-mobile-inbox-for-pull "~/Text/orgmob")
(require 'org-mobile-sync)
(org-mobile-sync-mode 1)
(setq org-agenda-files (quote ("~/Text/life.org" "~/Text/shopping.org"
                               "~/Text/movie-diary" "~/Text/books.org"
                               "~/Text/read.org" "~/Text/movies.org"
                               "~/schedule.org" "~/schedule2.org" "~/schedule3.org")))

(setq org-refile-targets '((org-agenda-files :maxlevel . 2)))

(add-hook 'org-agenda-mode-hook
          (lambda ()
            (visual-line-mode -1)
            (linum-mode -1)
            (toggle-truncate-lines 1)))

(require 'multicolumn)
(multicolumn-global-mode 1)

(setq org-agenda-property-list '("BECAUSE" "LASTCONTACT"))
;;(setq org-agenda-property-position 'next-line)


;;(setq enable-recursive-minibuffers t)

;; (defun org-completing-read (&rest args)
;;   "Completing-read with SPACE being a normal character."
;;   (let ((minibuffer-local-completion-map
;;          (copy-keymap minibuffer-local-completion-map)))
;;     (org-defkey minibuffer-local-completion-map " " 'self-insert-command)
;;     (org-defkey minibuffer-local-completion-map "?" 'self-insert-command)
;;     (org-defkey minibuffer-local-completion-map "!" 'org-time-stamp-inactive)
;;     (apply 'org-icompleting-read args)))

(setq org-agenda-sorting-strategy '(priority-down tag-up effort-down))
(setq org-agenda-include-all-todo t)
(setq org-habit-show-habits-only-for-today t)
(setq org-agenda-start-day "+0d")
(setq org-agenda-span 10)
(setq org-agenda-sticky nil)
(setq org-agenda-show-log t)
(setq org-agenda-skip-scheduled-if-done t)
(setq org-agenda-skip-deadline-if-done t)
(setq org-agenda-use-time-grid nil)

;; We gonna log stuff here.
(setq org-log-repeat 'time)
;; DONT LOG ORG-MODE-DONE IT FUX U
(setq org-log-done nil)
(require 'calendar)
(require 'org-gcal)
(setq org-gcal-client-id
      "824910591921-p3itqqfsatf78d58srtmq6uap1sm8107.apps.googleusercontent.com"
      org-gcal-client-secret "S6u-13T7HXv3WvfvUWs-yftw"
      org-gcal-file-alist '(
                            ("qefiaa27cig1mlij5v44e0orfo@group.calendar.google.com"
                             . "~/schedule2.org")
                            ("clara.raubertas@gmail.com" . "~/schedule.org")
                            ("n6ip1nkjfpdkkmdb3fhprujms4@group.calendar.google.com" . "~/schedule3.org")
                            ))

(org-gcal-fetch)

(defun org-gcal--notify (title mes) (let ((file (expand-file-name (concat (file-name-directory (locate-library "org-gcal")) org-gcal-logo))) (mes mes) (title title)) (if (eq system-type 'gnu/linux) (progn (if (not (file-exists-p file)) (deferred:$ (deferred:url-retrieve (concat " https://raw.githubusercontent.com/myuhe/org-gcal.el/master/" org-gcal-logo)) (deferred:nextc it (lambda (buf) (with-current-buffer buf (let ((tmp (substring (buffer-string) (+ (string-match "\n\n" (buffer-string)) 2)))) (erase-buffer) (fundamental-mode) (insert tmp) (write-file file))) (kill-buffer buf))))) (alert mes :title title :icon file)) (alert mes :title title)) ))

(setq org-agenda-prefix-format "%-2s")
(setq org-agenda-todo-keyword-format "")
(setq org-agenda-remove-tags 'prefix)
(setq org-agenda-show-all-dates t)

;; (setq org-agenda-custom-commands
;;       '(("h" "Daily habits" 
;;          ((agenda ""))
;;          ((org-agenda-show-log t)
;;           (org-agenda-ndays 7)
;;           (org-agenda-log-mode-items '(state))
;;           (org-agenda-skip-function '(org-agenda-skip-entry-if 'notregexp ":habit:"))))
;;         ;; other commands here

;;         ("n" "upcoming things that aren't habits/scheduled"
;;          ((tags-todo "-STYLE=\"habit\"-TODO=\"GETIT\""))
;;          ((org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled 'deadline)
;;                                     )
;;           (org-agenda-todo-keyword-format "%-5s")
;;           )
;;          )))


(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/Text/life.org" "Everys Thang")
         "* TODO %? %i %^g")
        ("j" "Jesse" entry (file+headline "~/Text/life.org" "Everys Thang")
         "* JESSE %? %i %^g")
        ("m" "Someday" entry (file+headline "~/Text/life.org" "Everys Thang")
         "* SOMEDAY/MAYBE %? %i %^g")
        ("w" "Waiting" entry (file+headline "~/Text/life.org" "Everys Thang")
         "* WAITING %? %i %^g")

	))


(set-face-attribute 'org-habit-alert-face nil :background "#fdf6e3"
		    :bold t :strike-through nil :foreground "#073642" :background "#eee8d5" 
		    )
(set-face-attribute 'org-habit-alert-future-face nil :background
		    "#fdf6e3" :strike-through nil :foreground "#2aa198"
		    :bold nil )
(set-face-attribute 'org-habit-clear-face nil :background "#fdf6e3"
		    :strike-through nil :bold nil :foreground "#2aa198")
(set-face-attribute 'org-habit-clear-future-face nil :background
		    "#fdf6e3" )
(set-face-attribute 'org-habit-overdue-face nil :background "#eee8d5"
		    :strike-through nil :foreground
		    "#b58900" :bold t )
(set-face-attribute 'org-habit-overdue-future-face nil :background
		    "#eee8d5" :strike-through nil :underline nil
                    )
(set-face-attribute 'org-habit-ready-face nil :background "#fdf6e3"
		    :foreground "#2aa198" :bold t 
		    )
(set-face-attribute 'org-warning nil :background "#fdf6e3"
		    :foreground "#b58900" :bold t 
		    )
(set-face-attribute 'org-upcoming-deadline nil :background "#fdf6e3"
		    :foreground "#268bd2" :bold t 
		    )

(set-face-attribute 'org-habit-ready-future-face nil :background
		    "#fdf6e3" )
(set-face-attribute 'org-level-1 nil :foreground "#073642" :height 120)
(set-face-attribute 'org-level-2 nil :foreground "#586e75" :height 100)
(set-face-attribute 'org-agenda-structure nil :foreground "#073642" :height 140 :background "#fdf6e3")
(setq org-habit-show-done-always-green t)
(setq org-habit-today-glyph ?★)
(setq org-habit-completed-glyph ?✓)

(setq org-habit-graph-column 28)

(setq org-columns-default-format "%40ITEM(Task) %5Effort(Effort){:} %6CLOCKSUM")
(setq org-agenda-tags-column 42)
(setq org-habit-preceding-days 8)
(setq org-habit-following-days 4)


(setq org-tag-faces
      '(
	("home" . (:inherit org-tag :foreground "#93a1a1" ))
	("computer" . (:inherit org-tag :foreground "#93a1a1" :weight demibold))
	("phone" .  (:inherit org-tag :foreground "#002b36" :weight bold) )
        ("malka" . (:inherit org-tag :foreground "#859900" :weight bold))
        ("hp" . (:inherit org-tag :foreground "#859900" :weight bold) )
        ("bathroom" . (:inherit org-tag :foreground "#2aa198" :weight demibold) )
        ("kitchen" . (:inherit org-tag :foreground "#268db2" :weight demibold) )
        ("frontroom" . (:inherit org-tag :foreground "#2aa198" :weight demibold))
        ("bedroom" . (:inherit org-tag :foreground "#2aa198" :weight demibold) )
        ("porch" .  (:inherit org-tag :foreground "#268db2" :weight demibold) )
        ("social" . "#6c71c4")
        ("railsbridge" . "#dc322f")
        ("para" . "#002b36")
	))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-calendar-event ((t (:foreground "#073642" :weight bold))))
 '(org-agenda-date ((t (:weight semi-bold :height 120 :foreground "#2aa198"))))
 '(org-agenda-date-today ((t (:weight bold :height 180 :foreground "#fdf6e3" :background "#2aa198"))))
 '(org-level-1 ((t nil)))
 '(org-scheduled ((t (:foreground "#2aa198" :weight bold :background "#fdf6e3"))))
 '(org-scheduled-previously ((t (:foreground "#d336a2" :weight bold :background "#fdf6e3"))))
 '(org-scheduled-today ((t (:foreground "#002b363" :bold nil :weight light ))))
 '(org-tag ((t ( :weight ultralight :height 100)))))


(setq org-priority-faces '((?A . (:foreground "#859900" :weight semibold))
                           (?B . (:foreground "#657b83" :weight ultralight))
                           (?C . (:foreground "#eee8d5" :weight ultralight))))

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


(setq org-agenda-custom-commands
      '(("o" "Office block agenda"
         (

          (agenda "" ((org-agenda-ndays 2)))
                    (tags-todo "+PRIORITY=\"A\"+TODO=\"TODO\""
                     ((org-agenda-overriding-header "⭒⭒⭒⭒⭸")
                      (org-agenda-skip-entry-if 'scheduled)
                      (org-agenda-sorting-strategy '(tag-up effort-down))
                      ) )
          (tags-todo "-PRIORITY=\"A\"-STYLE=\"habit\"+TODO=\"TODO\""
                     ( (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled 'deadline)) 
;;                      (org-agenda-skip-entry-if 'deadline)
                      (org-agenda-overriding-header "⭬⭬⭬⭬"))
                     )
;;          (tags "review" ((org-agenda-files '("~/org/circuspeanuts.org"))))
                          ;; limits the tag search to the file circuspeanuts.org
          (todo "WAITING"          ((org-agenda-overriding-header "⏳䷄…")))
          (todo "SOMEDAY/MAYBE" ((org-agenda-overriding-header "☁䷏…")))
          )
         ((org-agenda-compact-blocks t)) ;; options set here apply to the entire block
        ;; ...other commands here
        )))

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
(remove-hook 'text-mode-hook 'turn-on-auto-fill)
(global-linum-mode t)
;;;;;;;;;; ;;;;;;;;;;

;;;;;;;;;; IX. Text Mode ;;;;;;;;;;
;;;;;;;;;; ;;;;;;;;;;

(setq magit-last-seen-setup-instructions "1.4.0")


(push "<path-to-this-file>" load-path)





;; Useful key bindings for org-mode
(add-hook 'org-mode-hook
       (lambda ()
         (local-unset-key "\C-o")
         (local-set-key "\C-od" 'org-toodledo-mark-task-deleted)
         (local-set-key "\C-os" 'org-toodledo-sync)
         )
       )
(add-hook 'org-agenda-mode-hook
       (lambda ()
         (local-unset-key "\C-o")
         (local-set-key "\C-od" 'org-toodledo-agenda-mark-task-deleted)
         )
       )




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

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("79a3f477ac0cb4a106f78b6109614e991564a5c2467c36e6e854d4bc1102e178" "c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" default)))
 '(magit-use-overlays nil)
 '(rainbow-html-colors-major-mode-list
   (quote
    (html-mode css-mode php-mode nxml-mode xml-mode lisp-mode emacs-lisp-mode))))
