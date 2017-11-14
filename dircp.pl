#! /usr/bin/perl -w

use strict;
use File::Basename qw/dirname/;
use File::Copy qw/copy/;
use File::Path qw/make_path/;
use File::Spec;
use Getopt::Long;

my ($verbose)=0;
my ($logo)="dircp";


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

	print $fp "$0 [OPTIONS] [inputfiles...]\n";
	print $fp "\t--help|-h                   to display this help information\n";
	print $fp "\t--verbose|-v                to specified verbose\n";
	print $fp "\t--dest|-d <dir>             to specified the destition directory default is ..\n";
	print $fp "\t--source|-s <dir>           to specified the source directory default is .\n";
	print $fp "\n";
	print $fp "inputfiles...               to specified the files include every line files ,default stdin\n";
	
	exit($ec);
}

sub CopyDir($$$)
{
	my ($fp,$sd,$dd) = @_;
	while(<$fp>) {
		my ($f) = $_;
		my ($sf,$df);
		my ($bd,$bs);
		my ($mask);
		my (@stats);
		my ($ret);
		my ($s);
		chomp($f);
		$sf = File::Spec->catfile($sd,$f);
		$df = File::Spec->catfile($dd,$f);
		if ( -d "$sf" && ! -d "$df" ) {
			@stats = stat($sf);
			$mask = $stats[2] & 0777;
			$s = sprintf("mkdir [%s] mask[0%o]",$df,$mask);
			Debug("$s");
			make_path($df, {
				chmod => $mask,
				});
		} elsif ( -f "$sf" ) {
			$bd = dirname($df);
			if (! -e "$bd") {
				$bs = dirname($sf);
				@stats = stat($bs);
				$mask = $stats[2] & 0777;
				make_path($bd,{
					chmod => $mask,
					});
			}
			Debug("copy [$sf] => [$df]");
			$ret = copy($sf,$df);
			if ($ret == 0) {
				die "can not copy [$sf] => [$df] [$!]";
			}
		}
		# nothing to handle for the other type
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
	},
	"dest|d=s",
	"source|s=s");

if (defined($opts{"help"})){
	Usage(0,"");
}

if (defined($opts{"verbose"})) {
	$verbose=$opts{"verbose"};
}


my ($dstdir);
my ($srcdir);


$srcdir=".";
$dstdir="..";

if (defined($opts{'dest'})) {
	$dstdir = $opts{'dest'};
}

if (defined($opts{'source'})) {
	$srcdir = $opts{'source'};
}


if (scalar(@ARGV) > 0) {
	foreach (@ARGV) {
		my ($f) = $_;
		my ($fp);
		open($fp, "< $f") || die "can not open[$f] [$!]";
		CopyDir($fp,$srcdir,$dstdir);
		close($fp);
		undef($fp);
	}
} else {
	CopyDir(\*STDIN,$srcdir,$dstdir);
}

