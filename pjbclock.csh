#!/bin/csh
sleep 5
if ( "`stty size`" == "3 24" ) then
	# open ~/Active.datebk
	clear > /dev/tty
	pjbclock > /dev/tty
endif
#END
