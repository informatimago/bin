#!/bin/bash
date=$( date +"%Y-%m-%d %H:%M:%S" )
cpu_temp=$( awk '{print $3}' < /proc/sys/dev/sensors/w83782d-i2c-0-2d/temp2 )
mob_temp=$( awk '{print $3}' < /proc/sys/dev/sensors/w83782d-i2c-0-2d/temp1 )
cpu_fans=$( awk '{print $2}' < /proc/sys/dev/sensors/w83782d-i2c-0-2d/fan1 )
echo $date $mob_temp $cpu_temp $cpu_fans 
if [ $(awk "BEGIN{printf \"%d\",$cpu_temp*10;}"</dev/null) -gt 625 ] ; then
    halt -p
fi

