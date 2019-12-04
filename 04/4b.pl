#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use Data::Dumper;

my $sum;
NUMBER:
for my $i (134792 .. 675810) {
	my @digits = split //, $i;
	my $prev = 0;
	my %counts;

	for my $d (@digits) {
		next NUMBER if $d < $prev;
		$counts{$d}++;
		$prev = $d;
	}

	if (grep { $_ == 2 } (values %counts)) {
		$sum++
	}
}

say $sum
