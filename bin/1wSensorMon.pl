#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
use OW;

require "/usr/local/bin/1wMonConfig.pl";

our $OWINITSTR;
our %sensor_info;
our %cfgTemp;

use Tie::IxHash;
my %device_info;
tie(%device_info, "Tie::IxHash");
%device_info = %sensor_info;

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
OW::put($cfgTemp{'simultaneous'}, '1') if defined $cfgTemp{'simultaneous'};
while (my ($name, $device) = each(%sensor_info)) {
	next if (not defined $name or $name eq '');
	my $result = OW::get($device->{'owid'}.'/'.$device->{'owfn'});
	$result =~ s#\s+##g if defined($result);

	$result = (!defined ($result) || $result eq '') ? "U" : $result;
	$txtvals .= "\t".$result;
	$rrdvals{$name} = $result;
	print $name. (" "x(25-length($name))) .$result."\n" if ($opt{'verbose'});
}
OW::finish();

if (defined $cfgTemp{'TXTDB'}) {
	#write text table containing value history in clear text
	#if file does not exist yet, write the header
	my $print_txt_header = 0;
	$print_txt_header = 1 unless -f $cfgTemp{'TXTDB'};
	open TXTFH, ">>".$cfgTemp{'TXTDB'};
	#header for txt db
	if ($print_txt_header) {
		print TXTFH "ts";
		while (my ($name, $device) = each(%sensor_info)) {
			print TXTFH "\t".$name;
		}
		print TXTFH "\n";
	}
	$txtvals = $ts.$txtvals."\n";
	print TXTFH $txtvals;
	close TXTFH;
}

if (defined $cfgTemp{'CURTXTDB'}) {
	#write file with current values
	open TXTFH, ">".$cfgTemp{'CURTXTDB'};
	print TXTFH "ts\t$ts\n";
	my $txtval = "";
	while (my ($name, $device) = each(%sensor_info)) {
		next if (not defined $name or $name eq '');
		$txtval = $name."\t".$rrdvals{$name}."\n";
		print TXTFH $txtval;
	}
	close TXTFH;
}

if (defined $cfgTemp{'RRDDB'}) {
	use RRDTool::OO;

	# update rrd - error if there is not round-robin database
	die "Could not find RRD data file in $cfgTemp{'RRDDB'}\n" unless -f $cfgTemp{'RRDDB'};
	# rrd constructor
	my $rrd = RRDTool::OO->new(file => $cfgTemp{'RRDDB'});
	$rrd->update(time => $ts, values => \%rrdvals);
}

if (defined $cfgTemp{'INFLUXDB'}) {
	use LWP::UserAgent;
	use HTTP::Request;

	# Create a user agent object
	my $ua = LWP::UserAgent->new;
	$ua->timeout(15);
	my $influx_data = '';


	# Define the POST data
	while (my ($name, $device) = each(%sensor_info)) {
		next if (not defined $name or $name eq '');
		next if ($rrdvals{$name} eq 'U');
		$influx_data .= $cfgTemp{'INFLUXDB-PREFIX'} .' '. $name .'='. $rrdvals{$name} ."\n";
	}

	my $req = HTTP::Request->new('POST', $cfgTemp{'INFLUXDB'});
	$req->header('Content-Type' => 'text/plain');
	$req->content($influx_data);

	# Make the POST request
	my $response = $ua->request($req);

	# Check the response
	if (!$response->is_success && $opt{'verbose'}) {
		print "Influx HTTP POST failed: ". $response->status_line . "\n";
	}
}

if (defined $cfgTemp{'REST_JSON'}) {
	use JSON;
	use LWP::UserAgent;
	use HTTP::Request;

	# create copy of rrdvals with lower case keys
	my %rrdvals_lc = map { lc($_) => $rrdvals{$_} } keys %rrdvals;
	my $json_str = encode_json \%rrdvals_lc;

	# Create a user agent object
	my $ua = LWP::UserAgent->new;
	$ua->timeout(15);

	my $req = HTTP::Request->new('POST', $cfgTemp{'REST_JSON'});
	$req->header('Content-Type' => 'application/json');
	$req->content($json_str);

	# Make the POST request
	my $response = $ua->request($req);

	# Check the response
	if (!$response->is_success && $opt{'verbose'}) {
		print "REST JSON HTTP POST failed: ". $response->status_line . "\n";
	}
}
