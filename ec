#!/bin/bash
exec emacsclient --server-file /tmp/emacs1000/server-10800 "$@"
(emacs-pid)