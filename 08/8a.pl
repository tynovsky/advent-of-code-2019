#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);

my $input = <>;
chomp($input);

# my @layers = split /(?<=.{150})/, $input;
my @layers = unpack("(A150)*", $input);

say scalar(@layers);

my $min = "inf";
my %res;
my @result_layer;
for my $l (@layers) {
	my @chars = split //, $l;
	my ($zeros, $ones, $twos);
	for my $ch (@chars) {
		$zeros++ if $ch == 0;
		$ones++  if $ch == 1;
		$twos++  if $ch == 2;
	}
	$res{$zeros} = $ones * $twos;
	$min = $zeros if $zeros < $min;
}

say $res{$min};



