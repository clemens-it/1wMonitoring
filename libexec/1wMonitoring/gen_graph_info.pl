#!/usr/bin/perl -w
use strict;

require "/usr/local/bin/1wMonConfig.pl";

our %sensor_info;
our %cfgTemp;

print 'COMMENT:"\n"'. "\n";
print 'COMMENT:"                      "'. "\n";
print 'COMMENT:"Maximum   "'. "\n";
print 'COMMENT:"Average   "'. "\n";
print 'COMMENT:"Minimum   "'. "\n";
print 'COMMENT:" Last    \n"'. "\n\n";

my $i=0;
while (my ($k, $v) = each(%sensor_info)) {
	$i++;
	my $padding = " " x (22-length($v->{'label'}));
	print "DEF:draw$i=$cfgTemp{'RRDDB'}:" .$k. ":LAST\n";
	print "VDEF:dr".$i."max=draw$i,MAXIMUM\n";
	print "VDEF:dr".$i."min=draw$i,MINIMUM\n";
	print "VDEF:dr".$i."avg=draw$i,AVERAGE\n";
	print "VDEF:dr".$i."lst=draw$i,LAST\n";
	print "LINE1:draw$i" .$v->{'color'}. ":\"" .$v->{'label'}. "$padding\"\n";
	print "GPRINT:dr$i".'max:"%5.2lf"'."\n";
	print "GPRINT:dr$i".'avg:"%10.2lf"'."\n";
	print "GPRINT:dr$i".'min:"%10.2lf"'."\n";
	print "GPRINT:dr$i".'lst:"%10.2lf"'."\n";
	print 'COMMENT:"\l"'."\n\n";

}



########################################################
print "\n\n\n--------------------------------------------------------\n\n\n";
our %counter_info;
our %cfgCounter;
our $RRDSTEP;

print 'COMMENT:"\n"'. "\n";
print 'COMMENT:"                      "'. "\n";
print 'COMMENT:"Maximum   "'. "\n";
print 'COMMENT:"Average   "'. "\n";
print 'COMMENT:"Minimum   "'. "\n";
print 'COMMENT:"Last      "'. "\n";
print 'COMMENT:"Total    \n"'. "\n\n";

#$i=0;
while (my ($k, $v) = each(%counter_info)) {
	$i++;
	my $padding = " " x (22-length($v->{'label'}));
	print "DEF:ct$i=$cfgCounter{'RRDDB'}:" .$k. ":LAST\n";
	print "CDEF:data$i=ct$i,$v->{'factor'},*\n";
	print "CDEF:draw$i=ct$i,$v->{'factor'},*,$RRDSTEP,*\n";
	print "VDEF:dr".$i."max=draw$i,MAXIMUM\n";
	print "VDEF:dr".$i."min=draw$i,MINIMUM\n";
	print "VDEF:dr".$i."avg=draw$i,AVERAGE\n";
	print "VDEF:dr".$i."lst=draw$i,LAST\n";
	print "VDEF:dr".$i."tot=data$i,TOTAL\n";
	print "AREA:draw$i" .$v->{'color'}. ":\"" .$v->{'label'}. "$padding\"\n";
	print "GPRINT:dr$i".'max:"%5.2lf"'."\n";
	print "GPRINT:dr$i".'avg:"%10.2lf"'."\n";
	print "GPRINT:dr$i".'min:"%10.2lf"'."\n";
	print "GPRINT:dr$i".'lst:"%10.2lf"'."\n";
	print "GPRINT:dr$i".'tot:"%10.2lf"'."\n";
	print 'COMMENT:"\l"'."\n\n";

}

