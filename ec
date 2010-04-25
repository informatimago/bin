#!/bin/bash
unset TMPDIR
exec emacsclient "$@"
