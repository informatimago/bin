
set -u # error on uninitialized variables
set -e # exit on unhandled command error status


if [ ! -e $lockfile ]; then
   trap "rm -f $lockfile; exit" INT TERM EXIT
   touch $lockfile
   critical-section
   rm $lockfile
   trap - INT TERM EXIT
else
   echo "critical-section is already running"
fi
