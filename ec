#!/bin/bash
exec emacsclient --server-file /tmp/emacs1000/server-4984 "$@"
(emacs-pid)