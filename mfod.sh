#!/bin/bash
#**************************************************************************
#FILE:               mfod
#LANGUAGE:           bash shell
#SYSTEM:             unix
#USER-INTERFACE:     NONE
#DESCRIPTION
#    
#    Shows all the emacs servers available, and let the user select one
#    on which to open a new frame.
#    
#AUTHORS
#    <PJB> Pascal J. Bourguignon <pjb@informatimago.com>
#MODIFICATIONS
#    2009-09-12 <PJB> Created.
#BUGS
#LEGAL
#    GPL
#    
#    Copyright Pascal J. Bourguignon 2009 - 2010
#    
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License
#    as published by the Free Software Foundation; either version
#    2 of the License, or (at your option) any later version.
#    
#    This program is distributed in the hope that it will be
#    useful, but WITHOUT ANY WARRANTY; without even the implied
#    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#    PURPOSE.  See the GNU General Public License for more details.
#    
#    You should have received a copy of the GNU General Public
#    License along with this program; if not, write to the Free
#    Software Foundation, Inc., 59 Temple Place, Suite 330,
#    Boston, MA 02111-1307 USA
#**************************************************************************

select=0

pname="$(basename "$0")"
function usage(){
    printf "%s usage:\n    $s [select]\n" "$pname" "$pname"
}

for arg ; do 
    case "$arg" in
    select|-s|--select) select=1 ;;
    *) usage ; exit 1 ;;
    esac
done


sockets=()
for socket in /tmp/emacs$UID/server /tmp/emacs$UID/server-* ; do
    if [ -r $socket ] ; then
        sockets[${#sockets[@]}]=$socket
    fi
done

servers=()
frames=()
for socket in ${sockets[@]} ; do
    frame=$(emacsclient --socket-name="${socket}" --eval '(mapcar (function frame-name)  (frame-list))' 2>/dev/null || echo DEAD)
    if [ "$frame" = "DEAD" ] ; then
        # let's check there's no emacs process at that pid
        server_pid="${socket/*server-}"
        ps -p "$server_pid" | grep -s -q emacs || rm -f "${socket}"
    else
        servers[${#servers[@]}]="${socket}"
        frames[${#frames[@]}]="${frame}"
    fi
done

case ${#servers[@]} in 
0)
    printf "There is no emacs server.\n"
    exit 0
    ;;
1)
    server=${servers[0]}
    ;;
*)
    choice=-1
    while [ $choice -lt 0 -o  ${#sockets[@]} -le $choice ] ; do
        i=0
        while [ $i -lt ${#servers[@]} ] ; do
            printf "%2d) %-30s %s\n" "$i" "${servers[$i]}" "${frames[$i]}"
            i=$(( $i + 1 ))
        done
        if [ $select -eq 1 ] ; then
            read -p 'What instance must be the default emacs? ' index
        else
            read -p 'What instance do you want a frame from? ' index
        fi
        case x$index in
        x[Nn][Oo][Nn][Ee]|x[Cc][Aa][Nn][Cc][Ee][Ll]|x[Qq][Uu][Ii][Tt]|x[Aa][Bb][Oo][Rr][Tt])
            exit 0
            ;;
        x*[^0-9]*) 
            # search the index response into the frames lists.
            lindex=$( echo "$index" | tr '[:upper:]' '[:lower:]')
            choice=0
            found=no
            while [ $choice -lt ${#frames[@]} -a $found = no ] ; do 
                eval f=$(echo "${frames[$choice]}" | tr '[:upper:]' '[:lower:]')
                for frame in ${f[@]} ; do
                    if [ "$frame" = "$lindex" ] ; then
                        found=yes
                        break
                    fi
                done
                if [ $found = no ] ; then
                    choice=$(( $choice + 1 ))
                fi
            done
            if [ $found = no ] ; then
                printf "Please enter an integer between 0 and %d inclusive.\n" "$(( ${#servers[@]} - 1 ))"
                choice=-1
            fi
            ;;
        x*)
            choice=$index
            if  [ $choice -lt 0 -o  ${#servers[@]} -le $choice ] ; then
                printf "Please enter an integer between 0 and %d inclusive.\n" "$(( ${#servers[@]} - 1 ))"
            fi
            ;;
        esac
    done
    server=${servers[$choice]}
    ;;
esac

if [ $select -eq 1 ] ; then
    ln -sf $server /tmp/emacs$UID/server
else
    emacsclient --socket-name=${server} --no-wait --eval '(make-frame-on-display "'$DISPLAY'")'
fi

#### THE END ####
