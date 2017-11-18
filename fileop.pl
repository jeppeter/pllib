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
	print $fp "\tfilterurl [inputfiles]...          to filter output file\n";
	print $fp "[OPTIONS]\n";
	print $fp "\t--help|-h                   to display this help information\n";
	print $fp "\t--verbose|-v                to specified verbose\n";
	print $fp "\t--output|-o outfile         to specified the output default stdout\n";
	
	exit($ec);
}

sub dir_empty($)
{
	my ($rootdir) = @_;
	my ($dh);
	my ($cnt) = 0;
	my (@curdirs);
	my (@retdirs);

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
			@curdirs = &dir_empty($curd);
			foreach (@curdirs) {
				push(@retdirs, $_);
			}
		}
		closedir($dh);
		undef($dh);
		if ($cnt == 0) {
			push(@retdirs,$rootdir);
		}
	}
	return @retdirs;
}

sub filter_url($)
{
	my ($infp) = @_;
	my (@urls);

	while(<$infp>) {
		my ($l) = $_;
		chomp($l);
		if ( $l =~ m/<GET::([^\>]+)>/o) {
			push(@urls,$1);
		}
	}
	return @urls;
}

my (%opts);
my ($outfp) = \*STDOUT;
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

if (defined($opts{'output'})) {
	open($outfp, ">".$opts{'output'}) || die "can not open [".$opts{'output'}."] [$!]";
}

if ( "$subcmd" eq "dirempty" ) {
	my (@curdirs);
	my (@outdirs);
	my ($outfp) = \*STDOUT;
	if (scalar(@ARGV) > 0) {
		foreach (@ARGV) {
			@curdirs = dir_empty($_);
			foreach(@curdirs) {
				push(@outdirs, $_);
			}
		}
	} else {
		@outdirs =dir_empty(".");
	}

	foreach (@outdirs) {
		print $outfp "$_\n";
	}

} elsif ( "$subcmd" eq "filterurl" )  {
	my (@urls) ;
	my (@cururls);
	my ($fp);
	if (scalar(@ARGV) > 0) {
		foreach (@ARGV) {
			my ($f) =$_;
			open($fp, "<".$f) || die "can not open [$f] [$!]";
			@cururls = filter_url($fp);
			close($fp);
			foreach (@cururls) {
				push(@urls,$_);
			}
		}
	} else {
		@urls = filter_url(\*STDIN);
		Debug("urls [@urls]");
	}

	foreach (@urls) {
		print $outfp $_."\n";
	}

} else {
	Usage(3,"unknown subcmd [$subcmd]");
}

if ($outfp != \*STDOUT) {
	close($outfp);
}