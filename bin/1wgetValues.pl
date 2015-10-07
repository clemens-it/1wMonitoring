#!/usr/bin/perl -w
use strict;
use OW;

require "/usr/local/bin/1wMonConfig.pl";
our %sensor_info;
our $OWINITSTR;
our %cfgTemp;


my %values = ();
my %rrdvals = ();
my $txtvals;

#read temp values from sensors
OW::init($OWINITSTR);
OW::put($cfgTemp{'simultaneous'}, '1') if defined $cfgTemp{'simultaneous'};
while (my ($key, $sensor) = each(%sensor_info)) {
	my $name = $key;
	next if (not defined $name or $name eq '');
	my $result = OW::get($sensor->{'owid'}.'/'.$sensor->{'owfn'});
	$result =~ s#\s+##g if defined($result);

	$result = (!defined ($result) || $result eq '') ? "U" : $result;
	print $name. (" "x(25-length($name))). "$result\n";
}
OW::finish();

