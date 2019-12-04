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
	my $two_same = 0;

	for my $d (@digits) {
		next NUMBER if $d < $prev;
		$two_same = 1 if $d == $prev;
		$prev = $d;
	}

	$sum += $two_same
}

say $sum
