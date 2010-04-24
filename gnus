#!/bin/bash
EMACS=/usr/local/emacs-multitty/bin/emacs
EMACS=/usr/local/bin/emacs
EMACS=emacs
export EMACS_BG=\#ccccfefeebb7
exec $EMACS --eval "(gnus)"

