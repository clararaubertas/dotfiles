;;; sms.el --- Plain text-message view on top of Ement  -*- lexical-binding: t; -*-

;; Your Android texts are bridged into Matrix by mautrix-gmessages on
;; matrix.parallactic.com (pepper).  Ement does the talking to the server;
;; this file just shows the conversations like a phone would.
;;
;;   M-x sms        list of conversations, newest first
;;     RET          open conversation
;;     j / k        next / previous conversation
;;     c            text a new number
;;     a            archive (or unarchive) — also archives on your phone
;;     A            switch between inbox and archived conversations
;;     g            refresh
;;     q            close
;;
;;   In a conversation:
;;     r            reply
;;     RET          reply, or open the photo/file under the cursor
;;     o            open the photo/file under the cursor
;;     g            reload from the server
;;     q            back to the list
;;
;; New conversations from the bridge are accepted automatically.

;;; Code:

(require 'ement)
(require 'ement-room)
(require 'seq)
(require 'cl-lib)
(require 'subr-x)
(require 'svg)

(defgroup sms nil
  "Plain text-message view over Ement."
  :group 'ement)

(defcustom sms-bot-user-id "@gmessagesbot:matrix.parallactic.com"
  "Matrix ID of the Google Messages bridge bot."
  :type 'string)

(defcustom sms-hidden-room-names '("Google Messages bridge bot")
  "Rooms that are not text conversations (the bridge's control room)."
  :type '(repeat string))

;;;; Helpers

(defun sms--session ()
  "The (only) Ement session, or nil if not connected."
  (cdar ement-sessions))

(defun sms--room-name (room)
  (or (ement-room-display-name room)
      (ignore-errors (ement--room-display-name room))
      "?"))

(defun sms--my-id (session)
  (ement-user-id (ement-session-user session)))

(defcustom sms-self-ghost-id "@gmessages_1.414:matrix.parallactic.com"
  "Bridge stand-in account for you, used before double puppeting was set up.
Messages you sent from your phone before 2026-11-17 17:40 came from it;
since then the bridge posts them as your own account."
  :type '(choice (const :tag "None" nil) string))

(defun sms--self-ghost (_session)
  sms-self-ghost-id)

(defun sms--mine-p (event session)
  (let ((sender (ement-user-id (ement-event-sender event))))
    (or (equal sender (sms--my-id session))
        (equal sender (sms--self-ghost session)))))

(defvar sms--edits (make-hash-table :test #'equal)
  "Original event ID -> replacement content (from m.replace edits).
The bridge edits photo messages once full-size media arrives.")

(defun sms--edit-target (event)
  (let ((rel (alist-get 'm.relates_to (ement-event-content event))))
    (when (equal (alist-get 'rel_type rel) "m.replace")
      (alist-get 'event_id rel))))

(defvar sms--history (make-hash-table :test #'equal)
  "Room ID -> events fetched from the server's full history.
Ement itself only keeps the most recent handful per room.")

(defun sms--fetch-history (room session &optional then)
  "Fetch ROOM's whole history from the server, then call THEN."
  (let ((id (ement-room-id room)))
    (ement-api session (format "rooms/%s/messages" (url-hexify-string id))
      :timeout 60
      :params '(("dir" "b") ("limit" "1000"))
      :then (lambda (data)
              (puthash id (mapcar #'ement--make-event (append (alist-get 'chunk data) nil))
                       sms--history)
              (when then (funcall then)))
      :else (lambda (_) (message "SMS: couldn't load history for %s" (sms--room-name room))))))

(defun sms--messages (room &optional newest-first)
  "Message events in ROOM, oldest first (or NEWEST-FIRST).
Edits are folded into the message they replace."
  (let* ((all (seq-filter (lambda (e)
                            (and (equal (ement-event-type e) "m.room.message")
                                 (alist-get 'body (ement-event-content e))))
                          (append (ement-room-timeline room)
                                  (gethash (ement-room-id room) sms--history))))
         (seen (make-hash-table :test #'equal))
         (evs nil))
    ;; Oldest first, so later edits win; skip duplicates (timeline + history).
    (dolist (e (sort all (lambda (a b) (< (ement-event-origin-server-ts a)
                                          (ement-event-origin-server-ts b)))))
      (unless (gethash (ement-event-id e) seen)
        (puthash (ement-event-id e) t seen)
        (if-let ((target (sms--edit-target e)))
            (when-let ((new (alist-get 'm.new_content (ement-event-content e))))
              (puthash target new sms--edits))
          (push e evs))))
    ;; EVS is now newest first.
    (if newest-first evs (nreverse evs))))

(defun sms--latest (room)
  "Newest message in ROOM, looking only at Ement's recent timeline when possible."
  (let (best)
    (dolist (e (ement-room-timeline room))
      (when (and (equal (ement-event-type e) "m.room.message")
                 (alist-get 'body (ement-event-content e))
                 (not (sms--edit-target e))
                 (or (null best) (> (ement-event-origin-server-ts e)
                                    (ement-event-origin-server-ts best))))
        (setq best e)))
    (or best (car (sms--messages room t)))))

(defvar sms--show-archived nil
  "Non-nil when the list shows archived conversations instead of the inbox.")

(defvar sms--archive-override (make-hash-table :test #'equal)
  "Room ID -> \='archived or \='active, set locally until the server catches up.")

(defun sms--tagged-archived-p (room)
  "Non-nil if ROOM has the low-priority tag (what the bridge uses for archived)."
  (let* ((ad (seq-find (lambda (a) (equal (alist-get 'type a) "m.tag"))
                       (ement-room-account-data room)))
         (tags (alist-get 'tags (alist-get 'content ad))))
    (and (assq 'm.lowpriority tags) t)))

(defun sms--archived-p (room)
  (let* ((id (ement-room-id room))
         (override (gethash id sms--archive-override))
         (tagged (sms--tagged-archived-p room)))
    ;; Drop the local override once the server agrees, so later changes
    ;; from the phone (e.g. unarchived by a new text) show up.
    (when (and override (eq tagged (eq override 'archived)))
      (remhash id sms--archive-override)
      (setq override nil))
    (if override (eq override 'archived) tagged)))

(defun sms--conversation-p (room)
  (and (eq (ement-room-status room) 'join)
       (not (equal (ement-room-type room) "m.space"))
       (not (member (sms--room-name room) sms-hidden-room-names))
       (if sms--show-archived (sms--archived-p room) (not (sms--archived-p room)))))

(defun sms--conversations (session)
  "Joined text conversations as (ROOM . LATEST-EVENT), most recent first."
  (sort (mapcar (lambda (room) (cons room (sms--latest room)))
                (seq-filter #'sms--conversation-p (ement-session-rooms session)))
        (lambda (a b)
          (> (if (cdr a) (ement-event-origin-server-ts (cdr a)) 0)
             (if (cdr b) (ement-event-origin-server-ts (cdr b)) 0)))))

(defun sms--content (event)
  "EVENT's content, with any later edit applied."
  (or (gethash (ement-event-id event) sms--edits)
      (ement-event-content event)))

(defun sms--caption (content)
  "Caption text of a media message, or nil.
In Matrix, a media message's body is its caption when a separate
filename is given."
  (let ((body (alist-get 'body content))
        (filename (alist-get 'filename content)))
    (and filename body (not (equal filename body)) body)))

(defun sms--media-label (content)
  (pcase (alist-get 'msgtype content)
    ("m.image" "[photo]")
    ("m.video" "[video]")
    ("m.audio" "[voice message]")
    ("m.file" (format "[file: %s]" (or (alist-get 'filename content)
                                        (alist-get 'body content))))))

(defun sms--event-text (event)
  "One-line text for EVENT: the message, or a media label plus caption."
  (let* ((content (sms--content event))
         (label (sms--media-label content))
         (caption (sms--caption content)))
    (cond ((equal (alist-get 'msgtype content) "m.location") "[location]")
          (label (if caption (concat label " " caption) label))
          (t (alist-get 'body content)))))

;;;; Media (photos etc.)

(defconst sms--indent "    ")

(defcustom sms-image-max-width 400
  "Maximum width in pixels of photos shown in conversations."
  :type 'integer)

(defcustom sms-image-max-height 400
  "Maximum height in pixels of photos shown in conversations."
  :type 'integer)

(defvar sms--media-dir
  (expand-file-name "sms/" (or (getenv "XDG_CACHE_HOME") "~/.cache"))
  "Where downloaded photos and other media are cached.")

(defvar sms--media-pending (make-hash-table :test #'equal)
  "MXC URL -> callbacks waiting for that download.")

(defconst sms--media-extensions
  '(("image/jpeg" . "jpg") ("image/png" . "png") ("image/gif" . "gif")
    ("image/webp" . "webp") ("image/heic" . "heic") ("video/mp4" . "mp4")
    ("video/3gpp" . "3gp") ("audio/mp4" . "m4a") ("audio/amr" . "amr")
    ("audio/ogg" . "ogg") ("application/pdf" . "pdf")))

(defun sms--media-file (url mimetype)
  "Cache file name for media at mxc URL with MIMETYPE."
  (let ((id (replace-regexp-in-string "[^A-Za-z0-9_-]" "_"
                                      (replace-regexp-in-string "\\`mxc://" "" url))))
    (expand-file-name (concat id "." (or (cdr (assoc mimetype sms--media-extensions)) "bin"))
                      sms--media-dir)))

(defun sms--fetch-media (url mimetype callback)
  "Call CALLBACK with the local file for mxc URL, downloading it if needed."
  (let ((file (sms--media-file url mimetype)))
    (if (file-exists-p file)
        (funcall callback file)
      (push callback (gethash url sms--media-pending))
      (when (= 1 (length (gethash url sms--media-pending)))
        (ement--media-request url (sms--session)
          :as 'binary
          :then (lambda (data)
                  (make-directory sms--media-dir t)
                  (let ((coding-system-for-write 'binary))
                    (with-temp-file file
                      (set-buffer-multibyte nil)
                      (insert data)))
                  (let ((cbs (gethash url sms--media-pending)))
                    (remhash url sms--media-pending)
                    (dolist (cb cbs) (funcall cb file))))
          :else (lambda (_)
                  (remhash url sms--media-pending)
                  (message "SMS: couldn't download %s" url)))))))

(defun sms--open-file (file)
  (let ((process-connection-type nil))
    (start-process "sms-open" nil "xdg-open" file)))

;;;; Avatars

(defconst sms--avatar-colors
  '("#b58900" "#cb4b16" "#d33682" "#6c71c4" "#268bd2" "#2aa198" "#859900")
  "Solarized accents for initial-letter avatars.")

(defvar sms--avatar-cache (make-hash-table :test #'equal)
  "(KEY . SIZE) -> image.")

(defvar sms--avatar-px nil
  "When non-nil, the avatar size in pixels (bound by callers).")

(defun sms--avatar-size ()
  (or sms--avatar-px (round (* 1.2 (frame-char-height)))))

(defun sms--list-avatar-size ()
  "List avatars span the name line and the first preview line."
  (* 2 (default-line-height)))

(defun sms--member-event (room user-id)
  (seq-find (lambda (e) (and (equal (ement-event-type e) "m.room.member")
                             (equal (ement-event-state-key e) user-id)))
            (ement-room-state room)))

(defun sms--member-content (room user-id)
  (when-let ((ev (sms--member-event room user-id)))
    (ement-event-content ev)))

(defun sms--member-name (room user-id)
  (or (alist-get 'displayname (sms--member-content room user-id))
      user-id))

(defun sms--other-members (room session)
  "IDs of the other people in ROOM (not you, your stand-in, or the bot)."
  (let ((skip (list (sms--my-id session) (sms--self-ghost session) sms-bot-user-id))
        out)
    (dolist (e (ement-room-state room))
      (let ((uid (ement-event-state-key e)))
        (when (and (equal (ement-event-type e) "m.room.member")
                   (equal (alist-get 'membership (ement-event-content e)) "join")
                   (not (member uid skip))
                   (not (member uid out)))
          (push uid out))))
    (nreverse out)))

(defun sms--initial (name)
  (if (string-match "[[:alpha:]]" name)
      (upcase (match-string 0 name))
    "#"))

(defun sms--initials-avatar (initials seed size)
  (or (gethash (list initials seed size) sms--avatar-cache)
      (let* ((svg (svg-create size size))
             (r (/ size 2.0))
             (color (sms--color seed)))
        (svg-circle svg r r r :fill color)
        (svg-text svg initials :x r :y r :text-anchor "middle" :dominant-baseline "central"
                  :font-size (* size (if (> (length initials) 1) 0.38 0.48))
                  :font-weight "bold" :fill "#fdf6e3"
                  :font-family (face-attribute 'default :family nil t))
        (puthash (list initials seed size) (svg-image svg :ascent 'center) sms--avatar-cache))))

(defun sms--photo-avatar (file size)
  (or (gethash (cons file size) sms--avatar-cache)
      (let* ((svg (svg-create size size))
             (r (/ size 2.0))
             (clip (svg-clip-path svg :id "c"))
             (type (image-type-from-file-header file)))
        (svg-circle clip r r r)
        (svg-embed svg file (format "image/%s" (or type 'jpeg)) nil
                   :width size :height size :clip-path "url(#c)"
                   :preserveAspectRatio "xMidYMid slice")
        (puthash (cons file size) (svg-image svg :ascent 'center) sms--avatar-cache))))

(defvar sms--redraw-timer nil)

(defun sms--redraw-visible-soon ()
  (unless sms--redraw-timer
    (setq sms--redraw-timer
          (run-with-timer 0.5 nil
                          (lambda ()
                            (setq sms--redraw-timer nil)
                            (dolist (buf (buffer-list))
                              (when (get-buffer-window buf t)
                                (with-current-buffer buf
                                  (cond ((derived-mode-p 'sms-list-mode) (sms--list-render))
                                        ((derived-mode-p 'sms-conversation-mode) (sms--render)))))))))))

(defun sms--person-avatar (room user-id name)
  "Avatar image for USER-ID in ROOM: their photo, or their initial."
  (let* ((size (sms--avatar-size))
         (url (alist-get 'avatar_url (sms--member-content room user-id))))
    (if (null url)
        (sms--initials-avatar (sms--initial name) name size)
      (let ((file (sms--media-file url "image/jpeg")))
        (if (file-exists-p file)
            (sms--photo-avatar file size)
          (sms--fetch-media url "image/jpeg" (lambda (_) (sms--redraw-visible-soon)))
          (sms--initials-avatar (sms--initial name) name size))))))

(defun sms--color (seed)
  "The Solarized accent for SEED (a person's or conversation's name)."
  (nth (mod (string-to-number (substring (md5 seed) 0 6) 16)
            (length sms--avatar-colors))
       sms--avatar-colors))

(defun sms--room-color-seed (room session)
  "Seed matching the conversation's avatar colour."
  (let ((others (sms--other-members room session)))
    (if (= (length others) 1)
        (sms--member-name room (car others))
      (sms--room-name room))))

(defun sms--room-avatar (room session)
  "Avatar for a conversation: the other person's, or initials for a group."
  (let ((others (sms--other-members room session)))
    (if (= (length others) 1)
        (sms--person-avatar room (car others) (sms--member-name room (car others)))
      ;; Initials of the first two names in the conversation's name, so the
      ;; avatar matches what's shown (membership can include extra people).
      (let* ((names (seq-take (split-string (sms--room-name room) ", *" t) 2))
             (initials (mapconcat #'sms--initial names "")))
        (sms--initials-avatar initials (sms--room-name room) (sms--avatar-size))))))

(defcustom sms-row-padding 0.35
  "Height of the padding above and below each conversation in the list,
as a fraction of a normal line."
  :type 'number)

(defun sms--row-spacer ()
  (propertize "\n" 'face `(:height ,sms-row-padding)))

(defun sms--preview-indent ()
  "Space that lines a preview up under the conversation name."
  (if (display-graphic-p)
      (propertize " " 'display `(space :align-to (,(+ (* 3 (frame-char-width))
                                                         (sms--list-avatar-size)))))
    "    "))

(defun sms--avatar-slice (image half)
  "Top or bottom HALF of IMAGE, followed by a space."
  (concat (propertize " " 'display
                      `((slice 0 ,(if (eq half 'top) 0 0.5) 1.0 0.5) ,image))
          " "))

(defun sms--avatar-string (image)
  (if (display-graphic-p)
      (concat (propertize " " 'display image) " ")
    ""))

(defun sms-open-media ()
  "Open the photo, video or file at point in its usual app."
  (interactive)
  (if-let ((media (get-text-property (point) 'sms-media)))
      (progn (message "Opening...")
             (sms--fetch-media (car media) (cdr media) #'sms--open-file))
    (user-error "No photo or file here")))

(defun sms-save-media ()
  "Save the photo, video or file at point, by default to ~/Downloads as
\"<conversation> YYYY-MM-DD HH.MM.<ext>\"."
  (interactive)
  (let ((media (get-text-property (point) 'sms-media))
        (ts (get-text-property (point) 'sms-media-ts)))
    (unless media (user-error "No photo, video or file here"))
    (let* ((url (car media)) (mime (cdr media))
           (ext (file-name-extension (sms--media-file url mime)))
           (who (replace-regexp-in-string "[/:]" "-" (sms--room-name sms--room)))
           (base (if ts
                     (format "%s %s.%s" who (format-time-string "%Y-%m-%d %H.%M" (/ ts 1000.0)) ext)
                   (format "%s.%s" who ext)))
           (dest (expand-file-name
                  (read-file-name "Save to: " "~/Downloads/" nil nil
                                  (expand-file-name base "~/Downloads/"))
                  "~/Downloads/")))
      (when (file-directory-p dest) (setq dest (expand-file-name base dest)))
      (message "Saving...")
      (sms--fetch-media url mime
                        (lambda (file)
                          (copy-file file dest 1 t)
                          (message "Saved %s" (abbreviate-file-name dest)))))))

(defun sms-ret ()
  "Open the photo or file at point; otherwise reply."
  (interactive)
  (if (get-text-property (point) 'sms-media)
      (sms-open-media)
    (sms-reply)))

(defvar-local sms--render-timer nil)

(defun sms--schedule-render (buf)
  "Redraw conversation BUF shortly (coalesces many finished downloads)."
  (when (buffer-live-p buf)
    (with-current-buffer buf
      (unless sms--render-timer
        (setq sms--render-timer
              (run-with-timer 0.3 nil
                              (lambda ()
                                (when (buffer-live-p buf)
                                  (with-current-buffer buf
                                    (setq sms--render-timer nil)
                                    (sms--render))))))))))

(defun sms--insert-message-body (ev)
  "Insert EV's body: a photo inline, a labelled media line, or text."
  (let* ((content (sms--content ev))
         (msgtype (alist-get 'msgtype content))
         (url (alist-get 'url content))
         (mime (alist-get 'mimetype (alist-get 'info content)))
         (caption (sms--caption content))
         (props (list 'line-prefix sms--indent 'wrap-prefix sms--indent
                      'sms-media-ts (ement-event-origin-server-ts ev))))
    (cond
     ;; Photos: show inline once downloaded.
     ((and (equal msgtype "m.image") url (display-graphic-p))
      (let ((file (sms--media-file url mime)))
        (if (file-exists-p file)
            (let ((img (create-image file nil nil
                                     :max-width sms-image-max-width
                                     :max-height sms-image-max-height)))
              (insert (apply #'propertize " " 'display img 'sms-media (cons url mime)
                             'help-echo "RET: open full size" props)
                      "\n")
              (when (image-multi-frame-p img) (image-animate img nil 20)))
          (insert (apply #'propertize "[photo — loading…]\n" 'face 'sms-time
                         'sms-media (cons url mime) props))
          (let ((buf (current-buffer)))
            (sms--fetch-media url mime (lambda (_) (sms--schedule-render buf))))))
      (when caption
        (insert (apply #'propertize (concat caption "\n") 'face 'sms-text props))))
     ;; Other media: a label you can open with RET.
     ((and url (sms--media-label content))
      (insert (apply #'propertize (concat (sms--media-label content) "  (RET to open)\n")
                     'face 'sms-time 'sms-media (cons url mime) props))
      (when caption
        (insert (apply #'propertize (concat caption "\n") 'face 'sms-text props))))
     (t
      (insert (apply #'propertize (concat (or (sms--event-text ev) "") "\n")
                     'face 'sms-text props))))))

(defun sms--time (ms)
  (seconds-to-time (/ ms 1000.0)))

(defun sms--clock (time)
  (string-trim (format-time-string "%l:%M %p" time)))

(defun sms--short-when (ms)
  "Today: time.  This year: month and day.  Otherwise: date."
  (let* ((time (sms--time ms))
         (d (decode-time time))
         (now (decode-time)))
    (cond ((and (= (decoded-time-year d) (decoded-time-year now))
                (= (decoded-time-month d) (decoded-time-month now))
                (= (decoded-time-day d) (decoded-time-day now)))
           (sms--clock time))
          ((= (decoded-time-year d) (decoded-time-year now))
           (format-time-string "%b %-d" time))
          (t (format-time-string "%Y-%m-%d" time)))))

(defun sms--oneline (s)
  (replace-regexp-in-string "[\n\r]+" " " (or s "")))

(defun sms--find-room (id)
  (seq-find (lambda (r) (equal (ement-room-id r) id))
            (ement-session-rooms (sms--session))))

;;;; Auto-accept invites from the bridge

;; Ement 0.17's own join command rejects new-style room IDs (no ":server"),
;; and Synapse rate-limits joins, so join one invite per sync, retrying.

(defvar sms--join-attempts (make-hash-table :test #'equal)
  "Room ID -> time of last join attempt.")

(defun sms--accept-one-invite (session)
  (when-let ((room (seq-find
                    (lambda (r)
                      (and (eq (ement-room-status r) 'invite)
                           (let ((last (gethash (ement-room-id r) sms--join-attempts)))
                             (or (null last) (> (float-time (time-since last)) 15)))))
                    (ement-session-rooms session))))
    (puthash (ement-room-id room) (current-time) sms--join-attempts)
    (ement-api session (format "join/%s" (url-hexify-string (ement-room-id room)))
      :method 'post :data ""
      :then #'ignore
      :else #'ignore)))

;;;; Conversation list

;; Solarized palette.
(defface sms-name '((t :foreground "#268bd2" :weight bold))      ; blue
  "Names of other people.")
(defface sms-read-name '((t :foreground "#268bd2" :weight normal)) ; blue
  "Conversation names in the list when everything is read.")
(defface sms-me '((t :foreground "#2aa198" :weight bold))        ; cyan
  "Your own name (\"Me\").")
(defface sms-time '((t :foreground "#657b83" :weight normal))    ; base00
  "Timestamps and dates.")
(defface sms-unread '((t :foreground "#cb4b16" :weight bold))    ; orange
  "The unread marker.")
(defface sms-text '((t :foreground "#93a1a1" :weight normal))    ; base1
  "Message text (read).")
(defface sms-text-unread '((t :foreground "#eee8d5" :weight bold)) ; base2
  "Message text in the list when unread.")
(defface sms-row '((t :background "#05303b" :extend t))
  "Background of odd conversations in the list (just above base03).")
(defface sms-alt-row '((t :background "#093744" :extend t))
  "Background of even conversations in the list (near base02).")
(defface sms-hint '((t :foreground "#586e75" :weight normal))    ; base01
  "Key hints.")

(defun sms--preview-lines (text width)
  "Word-wrap TEXT to WIDTH; return at most two lines, with … if cut."
  (let* ((lines (with-temp-buffer
                  (insert text)
                  (let ((fill-column width)) (fill-region (point-min) (point-max)))
                  (split-string (buffer-string) "\n" t)))
         (shown (seq-take lines 2)))
    (when (> (length lines) 2)
      (setf (nth 1 shown)
            (concat (truncate-string-to-width (nth 1 shown) (1- width)) "…")))
    shown))

(defvar-keymap sms-list-mode-map
  :parent special-mode-map
  "RET" #'sms-open
  "j"   #'sms-next
  "k"   #'sms-previous
  "c"   #'sms-new
  "a"   #'sms-archive
  "A"   #'sms-toggle-archived)

(define-derived-mode sms-list-mode special-mode "SMS"
  "List of text conversations."
  (visual-line-mode -1)
  (display-line-numbers-mode -1)
  (setq truncate-lines t)
  (setq-local revert-buffer-function (lambda (&rest _) (sms--list-render))))

(defun sms--width ()
  (let ((w (get-buffer-window (current-buffer) t)))
    (if w (window-width w) 80)))

(defun sms--list-render ()
  "Redraw the conversation list, keeping point on the same conversation."
  (let* ((inhibit-read-only t)
         (session (sms--session))
         (here (get-text-property (point) 'sms-room))
         (width (sms--width))
         (row 0)
         (goto nil))
    (erase-buffer)
    (insert (propertize (if sms--show-archived "Archived texts" "Text messages")
                        'face '(bold :height 1.2)) "\n"
            (propertize (concat "RET open   j/k next/previous   c new text   "
                                (if sms--show-archived "a unarchive   A inbox" "a archive   A archived")
                                "   g refresh   q close")
                        'face 'sms-hint)
            "\n\n")
    (when session
      (dolist (pair (sms--conversations session))
        (let* ((room (car pair))
               (id (ement-room-id room))
               (ev (cdr pair))
               (unread (ignore-errors (ement--room-unread-p room session)))
               (when-str (if ev (sms--short-when (ement-event-origin-server-ts ev)) ""))
               (preview (if ev (sms--oneline (sms--event-text ev)) ""))
               (avatar (and (display-graphic-p)
                            (let ((sms--avatar-px (sms--list-avatar-size)))
                              (sms--room-avatar room session))))
               (start (point))
               (line1 nil))
          ;; Short spacer line for top padding (inside the row shading).
          (insert (sms--row-spacer))
          (setq line1 (point))
          (when (equal id here) (setq goto line1))
          ;; Line 1: marker, avatar (top half), name, time at the right edge.
          (insert (if unread (propertize "● " 'face 'sms-unread) "  ")
                  (if avatar (sms--avatar-slice avatar 'top) "")
                  (propertize (truncate-string-to-width
                               (sms--room-name room) (max 10 (- width 18)) nil nil "…")
                              'face (list :foreground (sms--color (sms--room-color-seed room session))
                                          :weight (if unread 'bold 'normal)))
                  (propertize " " 'display `(space :align-to (- right ,(1+ (length when-str)))))
                  (propertize when-str 'face 'sms-time)
                  "\n")
          ;; Lines 2-3: latest message, wrapped to at most two lines.
          (let* ((me (and ev (sms--mine-p ev session)))
                 (text (concat (if me "Me: " "") preview))
                 (face (if unread 'sms-text-unread 'sms-text))
                 (first t))
            (dolist (line (sms--preview-lines text (max 20 (- width 8))))
              (when (and first me (string-prefix-p "Me: " line))
                (setq line (concat (propertize "Me:" 'face 'sms-me)
                                   (propertize (substring line 3) 'face face))))
              (insert (if (and first avatar) (concat "  " (sms--avatar-slice avatar 'bottom))
                        (sms--preview-indent))
                      (if (get-text-property 0 'face line) line
                               (propertize line 'face face))
                      "\n")
              (setq first nil)))
          (insert (sms--row-spacer))
          (put-text-property start (point) 'sms-room id)
          (put-text-property line1 (1+ line1) 'sms-entry t)
          ;; Alternate row shading.
          (let ((ov (make-overlay start (point))))
            (overlay-put ov 'face (if (cl-oddp row) 'sms-alt-row 'sms-row))
            (overlay-put ov 'evaporate t))
          (setq row (1+ row)))))
    (goto-char (or goto (point-min)))
    (unless goto (sms-next))))

(defun sms--bot-room (session)
  (seq-find (lambda (r) (member (sms--room-name r) sms-hidden-room-names))
            (ement-session-rooms session)))

(defun sms-archive ()
  "Archive the conversation at point (unarchive it in the archived view).
Archives it on your phone too, via the patched bridge's archive command."
  (interactive)
  (let* ((session (sms--session))
         (room (sms--find-room (get-text-property (point) 'sms-room)))
         (bot (sms--bot-room session)))
    (unless room (user-error "No conversation on this line"))
    (unless bot (user-error "Can't find the bridge bot room"))
    (let* ((archiving (not (sms--archived-p room)))
           (id (ement-room-id room))
           (endpoint (format "user/%s/rooms/%s/tags/m.lowpriority"
                             (url-hexify-string (sms--my-id session))
                             (url-hexify-string id))))
      ;; Phone (via the bridge), then the server-side tag, then the screen.
      (ement-room-send-message bot session
                               :body (format "%s %s" (if archiving "archive" "unarchive") id))
      (if archiving
          (ement-api session endpoint :method 'put :data "{}" :then #'ignore :else #'ignore)
        (ement-api session endpoint :method 'delete :then #'ignore :else #'ignore))
      (puthash id (if archiving 'archived 'active) sms--archive-override)
      (sms-next)
      (sms--list-render)
      (message "%s %s" (if archiving "Archived" "Unarchived") (sms--room-name room)))))

(defun sms-toggle-archived ()
  "Switch between the inbox and archived conversations."
  (interactive)
  (setq sms--show-archived (not sms--show-archived))
  (goto-char (point-min))
  (sms--list-render))

(defun sms-next ()
  "Move to the next conversation."
  (interactive)
  (let ((pos (next-single-property-change (point) 'sms-entry)))
    (while (and pos (not (get-text-property pos 'sms-entry)))
      (setq pos (next-single-property-change pos 'sms-entry)))
    (when pos (goto-char pos))))

(defun sms-previous ()
  "Move to the previous conversation."
  (interactive)
  (let ((pos (previous-single-property-change (point) 'sms-entry)))
    (while (and pos (not (get-text-property pos 'sms-entry)))
      (setq pos (previous-single-property-change pos 'sms-entry)))
    (when pos (goto-char pos))))

(defun sms--after-connect (_session)
  "Show the list once connected, in the frame named \"sms\" if there is one."
  (remove-hook 'ement-after-initial-sync-hook #'sms--after-connect)
  (let ((frame (seq-find (lambda (f) (equal (frame-parameter f 'name) "sms")) (frame-list))))
    (if frame
        (with-selected-frame frame (sms))
      (sms))))

;; Ement pops up its own room list after connecting; sms replaces that.
(remove-hook 'ement-after-initial-sync-hook #'ement-room-list--after-initial-sync)

;;;###autoload
(defun sms ()
  "Show your text conversations."
  (interactive)
  (if (not (sms--session))
      (progn
        (add-hook 'ement-after-initial-sync-hook #'sms--after-connect 90)
        (message "Connecting to Matrix first...")
        (call-interactively #'ement-connect))
    (let ((buf (get-buffer-create "*SMS*")))
      (pop-to-buffer-same-window buf)
      (unless (derived-mode-p 'sms-list-mode) (sms-list-mode))
      (sms--list-render))))

(defun sms-open ()
  "Open the conversation at point."
  (interactive)
  (when-let ((room (sms--find-room (get-text-property (point) 'sms-room))))
    (sms--show-conversation room)))

(defun sms-new (number)
  "Start a text conversation with NUMBER."
  (interactive "sPhone number (e.g. +13125551234): ")
  (let* ((session (sms--session))
         (bot (seq-find (lambda (r) (member (sms--room-name r) sms-hidden-room-names))
                        (ement-session-rooms session))))
    (unless bot (user-error "Can't find the bridge bot room"))
    (ement-room-send-message bot session :body (concat "start-chat " (string-trim number)))
    (message "Asked the bridge to start a chat with %s; it'll appear in the list shortly"
             number)))

;;;; Conversation view

(defvar-local sms--room nil)
(defvar-local sms--last-read-id nil)

(defvar sms--pending nil
  "List of (ROOM-ID BODY NAME) for texts sent but not yet seen back.")

(defun sms--check-pending (session)
  "Report texts that have come back from the server as sent."
  (setq sms--pending
        (seq-remove
         (lambda (p)
           (pcase-let ((`(,id ,body ,name) p))
             (when-let ((room (sms--find-room id)))
               (when (seq-find (lambda (e)
                                 (and (equal (ement-event-type e) "m.room.message")
                                      (equal (ement-user-id (ement-event-sender e))
                                             (sms--my-id session))
                                      (equal (alist-get 'body (ement-event-content e)) body)))
                               (seq-take (ement-room-timeline room) 10))
                 (message "Sent to %s" name)
                 t))))
         sms--pending)))

(defvar-keymap sms-conversation-mode-map
  :parent special-mode-map
  "r"   #'sms-reply
  "RET" #'sms-ret
  "o"   #'sms-open-media
  "s"   #'sms-save-media
  "g"   #'sms-conversation-refresh
  "q"   #'sms-back)

(define-derived-mode sms-conversation-mode special-mode "SMS"
  "One text conversation."
  (display-line-numbers-mode -1)
  (visual-line-mode 1))

(defun sms--buffer-name (room)
  (format "*SMS: %s*" (sms--room-name room)))

(defun sms--show-conversation (room)
  (let ((buf (get-buffer-create (sms--buffer-name room))))
    (with-current-buffer buf
      (unless (derived-mode-p 'sms-conversation-mode) (sms-conversation-mode))
      (setq sms--room room)
      (sms--render)
      (goto-char (point-max)))
    (pop-to-buffer-same-window buf)
    (with-current-buffer buf (sms--mark-read))
    (sms--fetch-history room (sms--session)
                        (lambda ()
                          (when (buffer-live-p buf)
                            (with-current-buffer buf
                              (goto-char (point-max))
                              (sms--render)
                              (sms--mark-read)))))))


(defun sms--sender-name (room ev session)
  (if (sms--mine-p ev session)
      "Me"
    (or (ignore-errors (ement--user-displayname-in room (ement-event-sender ev)))
        (ement-user-id (ement-event-sender ev)))))

(defun sms--render ()
  "Redraw the current conversation buffer, keeping point unless at the end."
  (let* ((inhibit-read-only t)
         (session (sms--session))
         (room sms--room)
         (at-end (eobp))
         (pos (point))
         (last-day nil)
         (last-sender nil)
         (last-ts 0))
    (erase-buffer)
    (insert (propertize (sms--room-name room) 'face '(bold :height 1.2)) "\n"
            (propertize "r reply   RET/o open photo   g refresh   q back" 'face 'sms-hint)
            "\n")
    (dolist (ev (sms--messages room))
      (let* ((ts (ement-event-origin-server-ts ev))
             (time (sms--time ts))
             (day (format-time-string "%A, %B %-d, %Y" time))
             (mine (sms--mine-p ev session))
             (sender (sms--sender-name room ev session)))
        (unless (equal day last-day)
          (insert "\n" (propertize (concat "── " day " ──") 'face 'sms-time) "\n")
          (setq last-day day last-sender nil))
        ;; New heading when the sender changes or after a 10-minute gap.
        (unless (and (equal sender last-sender) (< (- ts last-ts) (* 10 60 1000)))
          (insert "\n"
                  (sms--avatar-string
                   (if mine
                       (sms--initials-avatar "Me" "me" (sms--avatar-size))
                     (sms--person-avatar room (ement-user-id (ement-event-sender ev)) sender)))
                  (propertize sender 'face (if mine 'sms-me
                                             (list :foreground (sms--color sender) :weight 'bold)))
                  (propertize (concat "  " (sms--clock time)) 'face 'sms-time)
                  "\n"))
        (setq last-sender sender last-ts ts)
        (sms--insert-message-body ev)))
    (if at-end
        (progn (goto-char (point-max))
               (dolist (w (get-buffer-window-list (current-buffer) nil t))
                 (set-window-point w (point-max))))
      (goto-char (min pos (point-max))))))

(defun sms--mark-read ()
  (when-let ((ev (sms--latest sms--room)))
    (unless (equal (ement-event-id ev) sms--last-read-id)
      (setq sms--last-read-id (ement-event-id ev))
      (ignore-errors
        (ement-room-mark-read sms--room (sms--session) :read-event ev :fully-read-event ev)))))

(defun sms-reply ()
  "Send a text in this conversation."
  (interactive)
  (let ((body (read-string (format "Text to %s: " (sms--room-name sms--room)))))
    (unless (string-empty-p (string-trim body))
      (ement-room-send-message sms--room (sms--session) :body body)
      (push (list (ement-room-id sms--room) body (sms--room-name sms--room)) sms--pending)
      (message "Sending to %s..." (sms--room-name sms--room)))))

(defun sms-conversation-refresh ()
  "Reload this conversation from the server."
  (interactive)
  (let ((buf (current-buffer)))
    (sms--fetch-history sms--room (sms--session)
                        (lambda ()
                          (when (buffer-live-p buf)
                            (with-current-buffer buf (sms--render)))))))

(defun sms-back ()
  "Close this conversation and go back to the list."
  (interactive)
  (quit-window)
  (sms))

;;;; Live updates

(defun sms--on-sync (session)
  "Refresh SMS buffers that are on screen.  Never let an error here
break Ement's sync loop; hidden buffers are redrawn when shown."
  (with-demoted-errors "SMS refresh error: %S"
    (sms--accept-one-invite session)
    (when sms--pending (sms--check-pending session))
    (sms--update-frame-titles)
    (dolist (buf (buffer-list))
      (when (get-buffer-window buf t)
        (with-current-buffer buf
          (cond ((derived-mode-p 'sms-list-mode)
                 (sms--list-render))
                ((and (derived-mode-p 'sms-conversation-mode) sms--room)
                 (sms--render)
                 (sms--mark-read))))))))

(add-hook 'ement-sync-callback-hook #'sms--on-sync)

;;;; Window title of the "sms" frame

;; The frame keeps the name "sms" (sms-frame.sh and the sway rule use it);
;; the `title' parameter is what's shown:
;;   list:          sms (3)     — number of unread conversations
;;   conversation:  sms (Mom)

(defun sms--unread-count (session)
  (let ((sms--show-archived nil))
    (seq-count (lambda (pair) (ignore-errors (ement--room-unread-p (car pair) session)))
               (sms--conversations session))))

(defun sms--frame-title (frame)
  (let ((buf (window-buffer (frame-selected-window frame)))
        (session (sms--session)))
    (with-current-buffer buf
      (cond ((and (derived-mode-p 'sms-conversation-mode) sms--room)
             (format "sms (%s)" (sms--room-name sms--room)))
            ((and (derived-mode-p 'sms-list-mode) session)
             (format "sms (%d)" (sms--unread-count session)))
            (t "sms")))))

(defun sms--update-frame-titles (&rest _)
  (with-demoted-errors "SMS title error: %S"
    (dolist (frame (frame-list))
      (when (equal (frame-parameter frame 'name) "sms")
        (let ((title (sms--frame-title frame)))
          (unless (equal title (frame-parameter frame 'title))
            (set-frame-parameter frame 'title title)))))))

(add-hook 'window-buffer-change-functions #'sms--update-frame-titles)
(add-hook 'window-selection-change-functions #'sms--update-frame-titles)

;;;; Keep Ement syncing

;; Ement gives up when the server restarts (e.g. Synapse upgrades) and
;; doesn't retry.  Check every minute and restart the sync if it's dead.

(defun sms--sync-watchdog ()
  (with-demoted-errors "SMS watchdog error: %S"
    (dolist (pair ement-syncs)
      (when (and (null (cdr pair)) ement-auto-sync)
        ;; `ement-syncs' is keyed by the session itself.
        (message "SMS: Matrix sync had stopped; restarting it")
        (ement--sync (car pair))))))

(defvar sms--watchdog-timer nil)
(when (timerp sms--watchdog-timer) (cancel-timer sms--watchdog-timer))
(setq sms--watchdog-timer (run-with-timer 60 60 #'sms--sync-watchdog))

(provide 'sms)
;;; sms.el ends here
