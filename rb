#!/bin/bash
dir=/alternate/movies/rocketboom
download_only=0
url_only=0
d=''
m=''
y=''
usage () {
    echo 'Usage: rb [--download-only|--url] [day [ month [ year ]]]'
}
for arg ; do
    case "$arg" in
    --download-only) download_only=1  ;;
    --url)           url_only=1       ;;
    -*)
        echo "Unknown argument: $arg"
        usage
        exit 1
        ;;
    [0-9]|[0-9][0-9]|[0-9][0-9][0-9][0-9])
        if [ -z "$d" ] ; then
            d=$arg
        elif [ -z "$m" ] ; then
            m=$arg
        elif [ -z "$y" ] ; then
            y=$arg
        else
            echo "Unknown argument: $arg"
            usage
            exit 1
        fi
        ;;
    esac
done

if [ -z "$y" ] ; then y=$(date +%Y) ; fi
if [ -z "$m" ] ; then m=$(date +%m) ; fi
if [ -z "$d" ] ; then d=$(date +%d) ; fi

if [ $m -gt 12 ] ; then
    usage
    exit 1
fi
if [ $d -gt 31 ] ; then
    usage
    exit 1
fi

y=$(( $y % 100 ))
yy=$(printf "%02d" "$y")
yyyy=$(printf "%04d" $(( 2000 + $y )) )
m=$(echo $m|sed -e 's/^0*//')
d=$(echo $d|sed -e 's/^0*//')
dd=$(echo 00$d|sed -e 's/.*\(..\)$/\1/')
months=(--- jan feb mar apr may jun jul aug sep oct nov dec)
mm=$(echo 0$m|sed -e 's/.*\(..\)$/\1/')
mmm=${months[$m]}
if [ ! -d $dir ] ; then
    echo "$dir absent"
    exit 1
fi
if [ $url_only -ne 0 ] ; then
    echo http://www.rocketboom.net/video/rb_${yy}_${mmm}_${dd}.wmv
elif [ -s $dir/rb-${yyyy}-${mm}-${dd}.wmv ] ; then
    mplayer -ontop -af volume=+9db $dir/rb-${yyyy}-${mm}-${dd}.wmv
else
    wget http://www.rocketboom.net/video/rb_${yy}_${mmm}_${dd}.wmv \
        -O $dir/rb-${yyyy}-${mm}-${dd}.wmv \
    && [ $download_only -eq 0 ] \
    && mplayer -ontop -af volume=+9db $dir/rb-${yyyy}-${mm}-${dd}.wmv
fi
