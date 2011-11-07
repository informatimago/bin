#!/bin/bash
. ~/.ansicodes

function goto () {
    echo -n "${CSI}${1};${2}H"
}

echo "${CLEAR_SCREEN}"
x=0
y=0
for b in WHITE CYAN MAGENTA YELLOW BLUE GREEN RED BLACK ; do
bb="$(echo "$b        "|sed -e 's/^\(........\).*$/\1/')"
g=${b}_BACK
for f in WHITE CYAN MAGENTA YELLOW BLUE GREEN RED BLACK ; do
goto $y $x;y=$(( $y + 1 ));if [ $y -eq 16 ];then y=0;x=$(( $x + 20 ));fi
ff="$(echo "        $f"|sed -e 's/^.*\(........\)$/\1/')"
echo -n "${!f}${!g}$ff on $bb ${NORMAL}"
done
done
y=16;x=0
for in in "" INVERT ; do
jin="$(echo "$in          "|sed -e 's/^\(........\).*$/\1/')"
for bl in "" BLINK  ; do
jbl="$(echo "$bl          "|sed -e 's/^\(........\).*$/\1/')"
for un in "" UNDERLINE ; do 
jun="$(echo "$un          "|sed -e 's/^\(........\).*$/\1/')"
for bo in "" BOLD ; do
jbo="$(echo "$bo          "|sed -e 's/^\(........\).*$/\1/')"
goto $y $x;y=$(( $y + 1 ))
echo -n "${!in}${!bl}${!un}${!bo}  $jin $jbl $jun $jbo    ${NORMAL}"
done
done
done
y=16;x=40
done
echo ''
#### ansi-test                        -- 2004-02-14 18:39:40 -- pascal   ####
