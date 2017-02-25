#! /usr/bin/env perl -w

use strict;
use Getopt::Long;

my ($verbose)=0;
my ($logo)="retest";

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

sub match_handler($$)
{
	my ($restr,$instr)=@_;
	if ($instr =~ m/$restr/){
		print STDOUT "[$instr] match [$restr]\n";
	} else {
		print STDOUT "[$instr] not match [$restr]\n";
	}
	return ;
}

sub findall_handler($$)
{
	my ($restr,$instr)=@_;
	my @matches;
	my ($i);

	@matches= $instr=~ /$restr/;
	if (scalar(@matches) > 0) {
		print STDOUT "[$restr] findall [$instr]\n";
		for($i=0;$i<scalar(@matches);$i++) {
			if (defined($matches[$i])) {
				print STDOUT "[$i] [".$matches[$i]."]\n";
			} else {
				print STDOUT "[$i] undefined\n";
			}
		}
	} else {
		print STDOUT "[$restr] find no matches [$instr]\n";
	}
	return;
}

sub sub_handler($$$)
{
	my ($fromstr,$tostr,$instr)=@_;
	my ($replaced)=$instr;
	$replaced =~ s/$fromstr/$tostr/;
	print STDOUT "[$instr] from [$fromstr] to [$tostr] [$replaced]\n";
	return;
}

sub Usage
{
	my ($ec,$fmt);
	my ($fp)=\*STDERR;
	$ec=1;
	$fmt="";
	if (scalar(@_) > 0) {
		$ec=shift @_;
	}
	if (scalar(@_) > 0) {
		$fmt = shift @_;
	}

	if ($ec == 0) {
		$fp = \*STDOUT;
	}

	if (length($fmt) > 0) {
		print $fp "$fmt\n";
	}

	print $fp "$0 [OPTIONS] [subcmds] ...\n";
	print $fp "[OPTIONS]\n";
	print $fp "\t-h|--help                              to display this help information\n";
	print $fp "\t-v|--verbose                           to specified verbose mode\n";
	print $fp "[subcmds]\n";
	print $fp "\tmatch restr instr...                   match string\n";
	print $fp "\tfindall restr instr...                 find all matches\n";	
	print $fp "\tsub fromstr [tostr] instr...           replace value\n";
	exit($ec);
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
	"simple|s");
if (defined($opts{"help"})){
	Usage(0,"");
}

if (defind($opts{"verbose"})) {
	$verbose=$opts{"verbose"};
}



if (scalar(@ARGV) < 2) {
	Usage(3,"need argv");
}

my ($cmd)=shift @ARGV;
my ($restr,$instr,$fromstr,$tostr);

if ($cmd eq "match") {
	if (scalar(@ARGV) < 2) {
		Usage(3,"match need [restr] [instr]");
	}
	$restr = shift @ARGV;
	foreach (@ARGV){
		match_handler($restr,$_);
	}
}  elsif ($cmd eq "findall") {
	if (scalar(@ARGV) < 2) {
		Usage(3,"match need [restr] [instr]");
	}
	$restr = shift @ARGV;
	foreach (@ARGV){
		findall_handler($restr,$_);
	}	
} elsif ($cmd eq "sub") {
	if (scalar(@ARGV) < 2) {
		Usage(3,"sub need [fromstr] [tostr] [instr]");
	}
	$fromstr = shift @ARGV;
	if (scalar(@ARGV) == 1) {
		$tostr = "";
	} else {
		$tostr = shift @ARGV;
	}
	foreach(@ARGV) {
		sub_handler($fromstr,$tostr,$_);
	}
} else {
	Usage(3,"[$cmd] not handled");
} 