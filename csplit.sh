#!/bin/sh
nlines=$1

if [ "$nlines" -lt 1 ] ; then
    echo "usage: $0 num-of-lines"
    exit 1
fi

nfile=0
filen=xx`echo 0$nfile|sed -e 's/.*\(..\)/\1/'`
i=0
while read line ; do
    echo "$line" >> $filen
    i=`expr $i + 1`
    if [ $i -ge $nlines ] ; then
        i=0
        nfile=`expr $nfile + 1`
        filen=xx`echo 0$nfile|sed -e 's/.*\(..\)/\1/'`
    fi
done

