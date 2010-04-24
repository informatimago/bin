#!/bin/bash
tr -d '\015\012' < "$1" \
| tr '<>' '\012\012' \
| sed -n -e 's/.*href="\(.*\.mov\)".*/\1/p' \
| head -1

