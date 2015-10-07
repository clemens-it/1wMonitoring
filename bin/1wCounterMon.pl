#!/usr/bin/perl -w
use strict;
use RRDTool::OO;
use Getopt::Long;
use OW;

require "/usr/local/bin/1wMonConfig.pl";
our $OWINITSTR;
our %counter_info;
our %cfgCounter; 

#handle command line options
my %opt = ();
my $gores = GetOptions(\%opt, "verbose");
exit 2 if (!$gores);


#save current timestamp as reference timestamp when storing data into
#different databases / text files
my $ts = time();
my %rrdvals = ();
my $txtvals = "";

#read values from devices
OW::init($OWINITSTR);
while (my ($name, $device) = each(%counter_info)) {
	next if (not defined $name or $name eq '');
	my $result = OW::get($device->{'owid'}.'/'.$device->{'owfn'});
	$result =~ s#\s+##g if defined($result);

	$result = (!defined ($result) || $result eq '') ? "U" : $result;
	$txtvals .= "\t".$result;
	$rrdvals{$name} = $result;
	print $name. (" "x(25-length($name))) .$result."\n" if ($opt{'verbose'});
}
OW::finish();

#write text table containing value history in clear text
#if file does not exist yet, write the header
my $print_txt_header = 0;
$print_txt_header = 1 unless -f $cfgCounter{'TXTDB'};
open TXTFH, ">>".$cfgCounter{'TXTDB'};
#header for txt db
if ($print_txt_header) {
	print TXTFH "ts";
	while (my ($name, $device) = each(%counter_info)) {
		print TXTFH "\t".$name;
	}
	print TXTFH "\n";
}
$txtvals = $ts.$txtvals."\n";
print TXTFH $txtvals;
close TXTFH;

#write file with current values
open TXTFH, ">".$cfgCounter{'CURTXTDB'};
print TXTFH "ts\t$ts\n";
my $txtval = "";
while (my ($name, $device) = each(%counter_info)) {
	next if (not defined $name or $name eq '');
	$txtval = $name."\t".$rrdvals{$name}."\n";
	print TXTFH $txtval;
}
close TXTFH;

# update rrd - error if there is not round-robin database
die "Could not find RRD data file in $cfgCounter{'RRDDB'}\n"  unless -f $cfgCounter{'RRDDB'};
# rrd constructor     
my $rrd = RRDTool::OO->new(file => $cfgCounter{'RRDDB'});
$rrd->update(time => $ts, values => \%rrdvals);

