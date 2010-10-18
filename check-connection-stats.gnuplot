set size 1024.0/1024, 768.0/768
set terminal png truecolor size 1024 768 enhanced font "Vera,9"
set output "/tmp/check-connection-stats.png"

set autoscale
set xtic auto
set ytic auto

set timefmt  "%Y-%m-%dT%H:%M:%S"

set format x "%H:%M\n%d/%m"
set xdata time
# set xr [2010.75:2010.80]

# set yr [1:105]
# set logscale y

set yr [-2:102]
set nologscale y

#"/tmp/check-connection.data" using 1:(100-$2) title "81.202.16.46"   with linespoints, \
#     
set key   right bottom
set title "Porciento de respuestas recibidas con ping"
set style line 3 lt "red" 
set style line 4 lt "red" 

plot "/tmp/check-connection.data" using 1:(100-$3) title "81.202.16.1"    with linespoints ls 3, \
     "/tmp/check-connection.data" using 1:(100-$4) title "74.125.39.105"  with points      ls 4

