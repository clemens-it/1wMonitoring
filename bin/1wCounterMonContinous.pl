#!/usr/bin/perl
use strict;
use Getopt::Long;
use OWNet;
use Proc::Daemon;
use IO::Handle;
# Needed for "Only allow one process of this script"-rule
use Fcntl ':flock'; # import LOCK_* constants

# requires packages libproc-daemon-perl, libownet-perl

require "/usr/local/bin/1wMonConfig.pl";
our %counter_info;
our %cfgCounter; 

#handle command line options
my %opt = ();
my $gores = GetOptions(\%opt, "verbose");
exit 2 if (!$gores);

my $interval = 60; # seconds between calls
my $flushfreq = 10; # output buffer shall be flushed after $flushfreq readings
my $startt = 0;
my $tb4 = 0;
my $flushct = 0;
my $TXTFH;
my $LOCKH;
#mutex
INIT {
	open $LOCKH, '>/var/lock/1wCounterMonContinous' or die "Can't open file for locking!\nError: $!\n";
	# lock file so that it can only be accessed by the current running script
	flock $LOCKH, LOCK_EX|LOCK_NB or die "$0 is already running!\n";
}

# Create owserver object
#my $owserver = OWNet->new('localhost:4304 -v -F') ; #default location, verbose errors, Fahrenheit degrees
my $owserver = OWNet->new() ; #simpler, again default location, no error messages, default Celsius

# sub will be called every $interval seconds
my $process = sub {
	my %rrdvals = ();
	my $txtvals = "";
	my $t = time;
	#print $t ."\t". ($t-$tb4) ."\n"; # debug
	$tb4 = $t;
	while (my ($name, $device) = each(%counter_info)) {
		next if (not defined $name or $name eq '');
		my $result = $owserver->read($device->{'owid'}.'/'.$device->{'owfn'});
		$result =~ s#\s+##g if defined($result);

		$result = (!defined ($result) || $result eq '') ? "U" : $result;
		$txtvals .= "\t".$result;
		$rrdvals{$name} = $result;
		print $name. (" "x(25-length($name))) .$result."\n" if ($opt{'verbose'});
	}
	$txtvals = $t.$txtvals."\n";
	print $TXTFH $txtvals;
	if ($flushct++ % $flushfreq == 0) {
		$TXTFH->flush();
	}
};

#Daemonize
Proc::Daemon::Init({ dont_close_fh => [ $LOCKH ]});

#write text table containing value history in clear text
#if file does not exist yet, write the header
my $print_txt_header = 0;
$print_txt_header = 1 unless -f $cfgCounter{'TXTDB'};

#open file 
open $TXTFH, ">>", $cfgCounter{'TXTDB'};

#turn off output buffering - debugging only
#my $old_fh = select($TXTFH);
#$| = 1;
#select($old_fh);

#header for txt db
if ($print_txt_header) {
	print $TXTFH "ts";
	while (my ($name, $device) = each(%counter_info)) {
		print $TXTFH "\t".$name;
	}
	print $TXTFH "\n";
}

my $continue = 1;
$SIG{TERM} = sub { $continue = 0; };
$SIG{HUP} = sub { $TXTFH->flush(); }; 

$startt = time;
&$process;
while ($continue) {
    sleep ($interval - ((time-$startt) % $interval));
    &$process;
}

close $TXTFH;
close $LOCKH;

