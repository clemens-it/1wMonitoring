#!/bin/bash

# Fills values from a text file into a rrd database using the command logtail.
# This is useful if the rrd database does not get updated automatically but 
# the values must be fed into it continuously by a cron script. 
# In that case this would be the initial readout of the file by logtail
#
# The rrd database must be created beforehand. For this the script
# gen_rrd_create.pl may be used

p=/srv/1wMonitoring
txt=$p/counter.txt
rrd=$p/counter.rrd
offs=$p/counter.offset
rrdvars=$(head -1 $txt | sed -e 's/^ts\t//; s/\t/:/g'; )
#first time read in
rm -f $offs
logtail -f $txt -o $offs | tail -n +2 | sed -e 's/\t/:/g' | xargs --no-run-if-empty rrdtool update $rrd -t $rrdvars

# if no column names are available
# test ! -z "$rrdvars" && logtail -f $txt -o $offs | sed -e 's/\t/:/g' | xargs --no-run-if-empty rrdtool update $rrd -t $rrdvars
