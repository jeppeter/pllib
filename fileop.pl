#! /usr/bin/perl -w

use strict;

use strict;
use File::Basename qw/dirname/;
use File::Copy qw/copy/;
use File::Path qw/make_path/;
use File::Spec;
use Getopt::Long;

my ($verbose)=0;
my ($logo)="fileop";


sub Debug($)
{
	my ($fmt)=@_;
	my ($fmtstr)="$logo ";
	if ($verbose > 0) {
		if ($verbose >= 3) {
			my ($p,$f,$l) = caller;
			$fmtstr .= "[$f:$l] ";
		}
		$fmtstr .= $fmt;
		print STDERR "$fmtstr\n";
	}
}


sub Usage($$)
{
	my ($ec,$fmt) = @_;
	my ($fp) = \*STDERR;

	if ($ec == 0) {
		$fp = \*STDOUT;
	}

	if (defined($fmt) && 
		length($fmt) > 0) {
		print $fp $fmt."\n";
	}

	print $fp "$0  [OPTIONS] [SUBCMD] [args...]\n";
	print $fp "[SUBCMD]\n";
	print $fp "\tdirempty  rootdir...               to handle find root dir\n";
	print $fp "[OPTIONS]\n";
	print $fp "\t--help|-h                   to display this help information\n";
	print $fp "\t--verbose|-v                to specified verbose\n";
	
	exit($ec);
}

sub dir_empty($)
{
	my ($rootdir) = @_;
	my ($dh);
	my ($cnt) = 0;

	if ( -d "$rootdir" ) {
		opendir($dh,"$rootdir") or die "can not open[$rootdir] [$!]";
		while(readdir($dh)) {
			my ($d) = $_;
			my ($curd) = File::Spec->catfile($rootdir,$d);
			if ($d eq "." ||
				$d eq ".." ) {
				next;
			}
			$cnt ++;
			&dir_empty($curd);
		}
		closedir($dh);
		undef($dh);
		if ($cnt == 0) {
			print "$rootdir\n";
		}
	}
	return;
}

my (%opts);
Getopt::Long::Configure("no_ignorecase","bundling");
Getopt::Long::GetOptions(\%opts,"help|h",
	"verbose|v" => sub {
		if (!defined($opts{"verbose"})) {
			$opts{"verbose"} = 0;
		}
		${opts{"verbose"}} ++;
	});

if (defined($opts{"help"})){
	Usage(0,"");
}

if (defined($opts{"verbose"})) {
	$verbose=$opts{"verbose"};
}


if (scalar(@ARGV) <= 0) {
	Usage(3,"need an subcmd");
}

my ($subcmd) = shift @ARGV;

if ( "$subcmd" eq "dirempty" ) {
	if (scalar(@ARGV) > 0) {
		foreach (@ARGV) {
			dir_empty($_);
		}
	} else {
		dir_empty(".");
	}
} else {
	Usage(3,"unknown subcmd [$subcmd]");
}