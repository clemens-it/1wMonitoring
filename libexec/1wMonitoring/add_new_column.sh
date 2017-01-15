# Takes over data from existing/current temperature.txt file and writes it into a new
# file adding new columns

# Do not attempt to execute this file like a bash script, this won't work. Rather
# copy line per line and paste it to the shell.
# The new columns have to be defined in the configuration file 1wMonConfig.pl already.

p=/srv/1wMonitoring
oritxt=$p/sensors.txt
orirrd=$p/sensors.rrd
tmptxt=$p/2sensors.txt
tmprrd=$p/2sensors.rrd

# The script gen_rrd_create wants to have a txt file ($oritxt) to read out the
# starting time for the rrd database. Make sure it exists and has at least one
# data line

# backup files
cp $oritxt $oritxt.bak
cp $orirrd $orirrd.bak

# clean up old "tmp files"
rm -rf $tmptxt $tmprrd

# The script gen_rrd_create.pl will generate code for creating one or two rrd
# databases (according to your config). Copy and paste the generated output
# for the corresponding rrd database into the shell
./gen_rrd_create.pl | sed -e "s#$orirrd#$tmprrd#g"

# Create new text files with additional columns. Adapt new column names below
# Command for multiple new columns. Note that for each column there must be a
# undefined value 'U' in the second part of the sed command.
sed -e '1s/$/\tKitchen_Temp\tKitchen_Humid\tStorage_Temp/; 2,$s/$/\tU\tU\tU/' $oritxt > $tmptxt

# Command for a single new column
newcol=Kitchen_Temp
sed -e "1s/\$/\t${newcol}/; 2,\$s/\$/\tU/" $oritxt > $tmptxt

# Feed the new text file into the new rrd file
rrdvars=$(head -1 $tmptxt | sed -e 's/^ts\t//; s/\t/:/g'; )
tail -n +2 $tmptxt | sed -e 's/\t/:/g' | xargs rrdtool update $tmprrd -t $rrdvars

# Overwrite original files with the newly created ones
mv $tmptxt $oritxt
mv $tmprrd $orirrd

