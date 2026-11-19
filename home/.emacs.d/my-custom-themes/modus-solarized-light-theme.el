
;; Modus+Solarized light
(defvar modus-solarized-light-palette
  (modus-themes-generate-palette
   ;; I provide the two base colors of Solarized, plus most of its
   ;; accents.  These form the BASE-COLORS I pass as an argument.
   ;; All other color values come from those.  The BASE-COLORS here
   ;; are enough to generate a new palatte that has no traces of, say,
   ;; the `modus-vivendi' color values.
   '((bg-main "#002b36")
     (fg-main "#EEE8D5")
     (red "#DC322F")
     (green "#859900")
     (yellow "#B58900")
     (blue "#268BD2")
     (magenta "#D33682")
     (cyan "#2AA198"))
   ;; The COOL-OR-WARM-PREFERENCE is derived internally based on
   ;; `bg-main'.  I can pass it here if I feel strongly about it.
   'warm
   ;; If I need to specify the CORE-PALETTE from where to inherit any
   ;; missing colors and/or semantic mappings, I can give it here.
   ;; Though nil is the appropriate starting point, as the code will
   ;; handle things internally.
   nil
   ;; And here are my MAPPINGS where I can specify what values apply
   ;; to which semantic color.  The `modus-themes-list-colors' shows
   ;; them all.
   ;;
   ;; Note that in my BASE-COLORS above I never wrote what, say,
   ;; `magenta-warmer' is: it is derived programmatically from the
   ;; `magenta' I have there.  Absent that, it would be taken from
   ;; the CORE-PALETTE.
   '((cursor magenta-warmer)
     (bg-hl-line bg-blue-nuanced)
     (bg-paren-match bg-magenta-subtle)
     (bg-region bg-blue-intense)
     (fg-region fg-dim)
     (bg-mode-line-active bg-blue-nuanced)
     (fg-mode-line-active blue-warmer)
     (border-mode-line-active blue-cooler))))

(modus-themes-theme
 'modus-solarized-light
 'modus-solarized-themes
 "Sample of a basic Solarized light port."
 'light
 'modus-solarized-light-palette
 nil

nil)
