while(<STDIN>) {
	my ($l) = $_;
	chomp($l);
	if (-f $l) {
		my @infos;
		@infos = stat($l);
		if (scalar(@infos) > 7) {
			print STDOUT $infos[7]." $l\n";
		}		
	}
}