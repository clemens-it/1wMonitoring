#!/bin/bash

# Fills values from a text file into a rrd database. The rrd database must be
# created beforehand. For this the script gen_rrd_create.pl may be used

p=/srv/1wMonitoring
txt=$p/sensors.txt
rrd=$p/sensors.rrd

rrdvars=$(head -1 $txt | sed -e 's/^ts\t//; s/\t/:/g'; )
tail -n +2 $txt | sed -e 's/\t/:/g' | xargs rrdtool update $rrd -t $rrdvars
