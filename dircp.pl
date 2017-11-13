#! /usr/bin/perl -w

use strict;
use File::Basename qw/dirname/;
use File::Copy qw/copy/;
use File::Path qw/make_path/;

my ($dstdir);
my ($srcdir);

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

	print $fp "$0 [OPTIONS] dstdir [srcdir]\n";
	print $fp "\t--help|-h                   to display this help information\n";
	print $fp "\t--verbose|-v                to specified verbose\n";
	print $fp "\t--file|-f <fileto list>     to specified the file line default stdin\n";
	
	exit($ec);
}

$srcdir=".";

if (scalar(@ARGV) > 0) {
	$dstdir= shift @ARGV;
}

if (scalar(@ARGV) > 0) {
	$srcdir = shift @ARGV;
}

while(<>){
	my ($filepat)=$_;
	my ($ddirn,$sdrin);
	my ($dn,$sn);
	chomp($filepat);
	$sn = "$srcdir/$filepat";
	$dn = "$dstdir/$filepat";
	$ddirn = dirname($dn);
	$sdrin = dirname($sn);

	if (! -e $ddirn ) {

	}


}