;;; init --- Init file of emacs
;;; Commentary:
"The shiohara init file of emacs and exwm."
;;; Code:

(package-initialize)

;; To prevent accidentally installing packages directly instead of through Nix,
;; nil is used as the addresses of archives.
(setq package-archives '(("gnu"          . nil)
                         ("gnu-devel"    . nil)
                         ("nongnu"       . nil)
                         ("nongnu-devel" . nil)
                         ("melpa"        . nil)
                         ("melpa-stable" . nil)))