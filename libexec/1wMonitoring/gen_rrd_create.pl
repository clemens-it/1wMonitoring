#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Tie::IxHash;

require "/usr/local/bin/1wMonConfig.pl";

our $RRDSTEP;

#
# Sensors
#
our %sensor_info;
our %cfgTemp;

my %device_info;
tie(%device_info, 'Tie::IxHash');
%device_info = %sensor_info;
my %cfg = %cfgTemp;

open(my $TFH, "<", $cfg{'TXTDB'})
	or die "Can't open file $cfg{'TXTDB'} for reading: $!";
#read the second line to get the first timestamp
<$TFH>;
my ($rrdstart, $rest) = split ("\t", <$TFH>);
$rrdstart -= ($RRDSTEP*2);
close($TFH);

print "rrdtool create $cfg{'RRDDB'} \\\n";
print "--step $RRDSTEP --start $rrdstart \\\n";
while (my ($k, $v) = each(%device_info)) {
	my $min = "U";
	my $max = "U";
	$max = $v->{'rrdmax'} if defined $v->{'rrdmax'};
	$min = $v->{'rrdmin'} if defined $v->{'rrdmin'};
	print "DS:".$k.":GAUGE:".($RRDSTEP*2).":$min:$max ";
}
print "\\\n";

# Archive MAX,MIN,AVG for every day - therefore compact number of primary data points PDP
# to one consolidated data point. Calc is done in seconds: seconds of a day divided by RRDSTEP
my $rradatapoints = (3600*24)/$RRDSTEP;
my $rrarows = 365*2; # two years in days
#my $datapoints = 1000000;
my $datapoints = 220000;

print "RRA:LAST:0.5:1:$datapoints ";
print "RRA:MAX:0.5:$rradatapoints:$rrarows ";
print "RRA:MIN:0.5:$rradatapoints:$rrarows ";
print "RRA:AVERAGE:0.5:$rradatapoints:$rrarows \n";
print "\n\n";


#
# Counters
#
our %counter_info;
our %cfgCounter;

tie(%device_info, 'Tie::IxHash');
%device_info = %counter_info;
%cfg = %cfgCounter;

$RRDSTEP=60;

open($TFH, "<", $cfg{'TXTDB'})
	or die "Can't open file $cfg{'TXTDB'} for reading: $!";
#read the second line to get the first timestamp
<$TFH>;
($rrdstart, $rest) = split ("\t", <$TFH>);
$rrdstart -= ($RRDSTEP*2);
close($TFH);

print "rrdtool create $cfg{'RRDDB'} \\\n";
print "--step $RRDSTEP --start $rrdstart \\\n";
while (my ($k, $v) = each(%device_info)) {
	print "DS:".$k.":COUNTER:".($RRDSTEP*2).":U:U ";
}
print "\\\n";

# Archive MAX,MIN,AVG for every day - therefore compact number of primary data points PDP
# to one consolidated data point. Calc is done in seconds: seconds of a day divided by RRDSTEP
$rradatapoints = (3600*24)/$RRDSTEP;
$rrarows = 365*2; # two years in days
#my $datapoints = 1000000;
$datapoints = 500000;

print "RRA:LAST:0.5:1:$datapoints ";
print "RRA:MAX:0.5:$rradatapoints:$rrarows ";
print "RRA:MIN:0.5:$rradatapoints:$rrarows ";
print "RRA:AVERAGE:0.5:$rradatapoints:$rrarows \n";
print "\n\n";

exit;
