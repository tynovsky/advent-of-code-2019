#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use Math::Trig;
use Data::Dumper;


my $asteroids = [];
while (<>) {
    chomp;
    push @$asteroids, [ map {$_ eq '#' ? 1 : 0} (split //, $_) ];
}

# print Dumper $asteroids;

my %visible_counts;
for my $i (0 .. scalar(@$asteroids) - 1) {
    for my $j (0 .. scalar(@{$asteroids->[0]}) - 1) {
        next if ! $asteroids->[$i][$j];
        my $visible_count = visible_count($i, $j, $asteroids);
        say "$i, $j => $visible_count";
        $visible_counts{$visible_count} = [$i, $j];
    }
}

my $max_count = (reverse sort {$a <=> $b} keys %visible_counts)[0];

print Dumper $visible_counts{$max_count};
say $max_count;


sub visible_count {
    my ($x, $y, $asteroids) = @_;
    my %visible_angles;
    for my $i (0 .. scalar(@$asteroids) - 1) {
        for my $j (0 .. scalar(@{$asteroids->[0]}) - 1) {
            next if !$asteroids->[$i][$j];
	    next if $x == $i && $y == $j;
            my $angle;
            if ($j == $y) {
                $angle = 0;
            } 
            else {
                $angle = sprintf("%.4f", atan(($i - $x) / ($j - $y)));
            }
            $angle += pi if $i < $x && $j < $y;

            $visible_angles{$angle}++;
        }
    }
    return scalar(keys %visible_angles)
}
