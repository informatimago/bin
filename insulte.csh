#!/bin/csh -f 
set path=(/local/bin $path)
set insults=/users/pascal/private/notes/insultes-haddock.txt

set nm=(`cat <$insults|egrep '	.*n[^f]'|tr ' ' '_'|sed -e 's/	.*//'`)
set nf=(`cat <$insults|egrep '	.*n[^mp]'|tr ' ' '_'|sed -e 's/	.*//'`)
set ad=('' `cat <$insults|egrep '	.*a'|tr ' ' '_'|sed -e 's/	.*//'`)

set n=0
@ n = 1 + `random $#ad` * `random 2`
set ga="$ad[$n]"
if ( "$ga" != "" ) then
	set ga=" $ga"
endif

@ n = $#nm + $#nf
@ n = 1 + `random $n`
if ( $n > $#nm ) then
	@ n -= $#nm
	set gn="$nf[$n]"
	switch ( "$ga" )
	case '':
		breaksw
	case "*/'e":
		set ga="${ga}e"
		breaksw
	case '*[e]':
		breaksw
	case '*eur':
		set ga=`echo "$ga"|sed -e 's/eur$/euse/'`
		breaksw
	default:
		set ga="${ga}e"
		breaksw
	endsw
else
	set gn="$nm[$n]"
endif

switch ( $gn )
case '[aeiouyh]*':
	set conj="d'"
	breaksw
default:
	set conj='de '
	breaksw
endsw

switch ( `random 4` )
case 0:
	set ins='Esp/`ece '"${conj}${gn}${ga}"
	breaksw
case 1:
	set ins="Bande ${conj}${gn}${ga}"
	breaksw
default:
	set ins=`capitalize "${gn}"`"${ga}"
	breaksw
endsw
echo "   $ins \!"|tr '_' ' '|sevenbit -8 --escape-char /
exit

echo $nm
echo $nf
echo $ad
exit 0

#### insulte                          --                     --          ####
