#!/bin/bash

# Feeds data from text file into rrd database. Text file is read using the
# command logtail starting from the offset to which it was read the last time.
#
# Initial read should be done using the script fill_txt_into_rrd_logtail.sh.

p=/srv/1wMonitoring
txt=$p/counter.txt
rrd=$p/counter.rrd
offs=$p/counter.offset
rrdvars=$(head -1 $txt | sed -e 's/^ts\t//; s/\t/:/g'; )

test ! -z "$rrdvars" && logtail -f $txt -o $offs | sed -e 's/\t/:/g' | xargs --no-run-if-empty rrdtool update $rrd -t $rrdvars
