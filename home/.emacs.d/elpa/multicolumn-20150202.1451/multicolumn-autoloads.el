;;; multicolumn-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (or (file-name-directory #$) (car load-path)))

;;;### (autoloads nil "multicolumn" "multicolumn.el" (22397 18856
;;;;;;  927314 922000))
;;; Generated autoloads from multicolumn.el

(autoload 'multicolumn-resize-frame "multicolumn" "\
Resize and position frame to accommodate multiple side-by-side windows.

With \\[universal-argument], prompt for window width and number
of windows.

Return intended number of windows, or nil in case there is no
window system.

\(fn &optional WIDTH-IN-CHARS NUMBER-OF-WINDOWS)" t nil)

(autoload 'multicolumn-resize-and-split-frame "multicolumn" "\
Resize, position, and split frame with multiple side-by-side windows.

With \\[universal-argument], prompt for window width and number
of windows.

\(fn &optional WIDTH-IN-CHARS NUMBER-OF-WINDOWS)" t nil)

(autoload 'multicolumn-split "multicolumn" "\
Split selected window horizontally into side-by-side windows.

Split into NUMBER-OF-WINDOWS windows. Should it be nil, create as
many windows as possible as long as they will not become narrower
than `multicolumn-min-width'.

\(fn &optional NUMBER-OF-WINDOWS)" t nil)

(autoload 'multicolumn-delete-other-windows-and-split "multicolumn" "\
Fill frame with buffer of selected window in ARG side-by-side windows.

Should NUMBER-OF-WINDOWS be nil as many windows as possible are
created as long as they are will not become narrower than
`multicolumn-min-width'.

The previous window layout can be restored using
`multicolumn-pop-window-configuration'.

\(fn &optional NUMBER-OF-WINDOWS)" t nil)

(autoload 'multicolumn-delete-other-windows-and-split-with-follow-mode "multicolumn" "\
Fill frame with selected window in ARG windows with `follow-mode' enabled.

Should NUMBER-OF-WINDOWS be nil as many windows as possible are
created as long as they are will not become narrower than
`multicolumn-min-width'.

The previous window layout can be restored using
`multicolumn-pop-window-configuration'.

\(fn &optional NUMBER-OF-WINDOWS)" t nil)

(autoload 'multicolumn-pop-window-configuration "multicolumn" "\
Go back to the previous window configuration.

\(fn)" t nil)

(autoload 'multicolumn-collect-windows "multicolumn" "\
Make sure windows displaying the same buffer are adjacent.

\(fn)" t nil)

(autoload 'multicolumn-transpose-windows "multicolumn" "\
Swap the buffers of the current and the next window.

\(fn)" t nil)

(autoload 'multicolumn-swap-windows-content "multicolumn" "\
Swap buffers of WIN1 and WIN2.

\(fn WIN1 WIN2)" nil nil)

(autoload 'multicolumn-extend-right "multicolumn" "\
Display the current buffer in the next window to the right.

\(fn)" t nil)

(autoload 'multicolumn-extend-left "multicolumn" "\
Display the current buffer in the next window to the left.

\(fn)" t nil)

(autoload 'multicolumn-select-first-window "multicolumn" "\
Select the leftmost window in the frame.

\(fn)" t nil)

(autoload 'multicolumn-select-last-window "multicolumn" "\
Select the rightmost window in the frame.

\(fn)" t nil)

(autoload 'multicolumn-select-previous-window "multicolumn" "\
Select previous window.

\(fn)" t nil)

(autoload 'multicolumn-select-window-number "multicolumn" "\
Select window NUMBER, where 1 is the leftmost.

When called interactively, this is assumed to be bound to a key
seqeunce ending in a digit.

\(fn NUMBER)" t nil)

(autoload 'multicolumn-select-minibuffer "multicolumn" "\
Select the minibuffer, if visible.

\(fn)" t nil)

(defvar multicolumn-global-mode nil "\
Non-nil if Multicolumn-Global mode is enabled.
See the command `multicolumn-global-mode' for a description of this minor mode.")

(custom-autoload 'multicolumn-global-mode "multicolumn" nil)

(autoload 'multicolumn-global-mode "multicolumn" "\
Global minor mode for creating and managing side-by-side windows.

\(fn &optional ARG)" t nil)

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; multicolumn-autoloads.el ends here
