#!/bin/bash
source ~/.bashenv-emacs
exec emacsclient -s "$EMACS_SERVER_FILE" "$@"
########################################################################
unset TMPDIR
if [ ! -e "$socket" ] ; then
    mfod -s 1
fi
for ec in \
		/Applications/Emacs.app/Contents/MacOS/bin/emacsclient \
		/usr/local/bin/emacsclient \
		emacsclient ; do
    if [ -x "$ec" ] ; then
        echo "$ec" "--socket-name" "$socket" "$@"
        "$ec" "--socket-name" "$socket" "$@"
        status=$?
        if ((status==0)) ; then
            exit
        fi
    fi
done
echo "No emacsclient."
if [ "$VISUAL" != "ec" ] ; then
    echo "Trying $VISUAL"
    "$VISUAL" "$@" 
fi || \
    if [ "$EDITOR" != "ec" ] ; then
        echo "Trying $EDITOR"
        "$EDITOR" "$@"
    fi
