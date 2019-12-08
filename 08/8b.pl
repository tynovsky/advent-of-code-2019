#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);

my $input = <>;
chomp($input);

# my @layers = split /(?<=.{150})/, $input;
my @layers = unpack("(A150)*", $input);

say scalar(@layers);

my @result_layer = (undef) x 150;
for my $l (@layers) {
	my @chars = split //, $l;
	for my $i (0 .. $#chars) {
		if ($chars[$i] != 2) {
			$result_layer[$i] //= ($chars[$i] == 1) ? '■' : ' ';
		}
	}
}

my $i = 0;
for my $r (@result_layer) {
	say "" if $i++ % 25 == 0;
	print $r;
}



