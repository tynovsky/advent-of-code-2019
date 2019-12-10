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

my $total = 0;
my %visible_counts;
for my $i (0 .. scalar(@$asteroids) - 1) {
    for my $j (0 .. scalar(@{$asteroids->[0]}) - 1) {
        next if ! $asteroids->[$i][$j];
        $total++;
        my $visible_count = visible_count($i, $j, $asteroids);
        $visible_counts{$visible_count} = [$i, $j];
    }
}

my $max_count = (reverse sort {$a <=> $b} keys %visible_counts)[0];

my ($x, $y) = @{$visible_counts{$max_count}}[0,1];
my $visible_asteroids = visible_asteroids($x, $y, $asteroids);

my $distance = sub { abs($x - $_[0]->[0]) + abs($y - $_[0]->[1]) };
for my $k (sort keys %$visible_asteroids) {
    $visible_asteroids->{$k} = [
        sort {$distance->($a) <=> $distance->($b)} @{$visible_asteroids->{$k}}
    ]
}

my $vaporized = 0;
while ($vaporized < $total - 1) {
    say "NEXT ROUND";
    for my $k (sort keys %$visible_asteroids) {
        next if scalar(@{$visible_asteroids->{$k}}) == 0;
        my $asteroid = shift @{$visible_asteroids->{$k}};
        my $dist = $distance->($asteroid);
        say ++$vaporized, ". [$asteroid->[0], $asteroid->[1]] (angle $k, distance $dist)";
        # for my $i (0 .. scalar(@$asteroids) - 1) {
        #     for my $j (0 .. scalar(@{$asteroids->[0]}) - 1) {
        #         if ($i == $asteroid->[0] && $j == $asteroid->[1]) {
        #             print "X";
        #             $asteroids->[$i][$j] = 0;
        #             next
        #         }
        #         if ($i == $x && $j == $y) {
        #             print "O ";
        #             next
        #         }
        #         print $asteroids->[$i][$j] ? '# ' : '. ';
        #     }
        #     print "\n"
        # }
    }
}

sub visible_asteroids {
    my ($x0, $y0, $asteroids) = @_;
    my %visible_asteroids;
    for my $i (0 .. scalar(@$asteroids) - 1) {
        for my $j (0 .. scalar(@{$asteroids->[0]}) - 1) {
            next if !$asteroids->[$i][$j];
	    next if $x0 == $i && $y0 == $j;

            my $angle = angle($x0, $y0, $i, $j);
	    $visible_asteroids{$angle} //= [];
            push @{$visible_asteroids{$angle}}, [$i, $j];
        }
    }
    return \%visible_asteroids;
}

sub visible_count {
    my ($x0, $y0, $asteroids) = @_;
    my %visible_angles;
    for my $i (0 .. scalar(@$asteroids) - 1) {
        for my $j (0 .. scalar(@{$asteroids->[0]}) - 1) {
            next if !$asteroids->[$i][$j];
	    next if $x0 == $i && $y0 == $j;
            my $angle = angle($x0, $y0, $i, $j);
            $visible_angles{$angle}++;
        }
    }
    return scalar(keys %visible_angles)
}

sub angle {
    my ($x0, $y0, $i, $j) = @_;

    my $x = $x0 - $i;
    my $y = $j - $y0;

    my $angle;
    if ($x == 0) {
        $angle = $y == 0 ? 0 : ($y > 0) ? pi/2 : 3*pi/2;
    }
    elsif ($x >= 0 && $y >= 0) {
        $angle = atan($y / $x);
    }
    elsif ($x < 0 && $y >= 0) {
        $angle = atan($y / $x) + pi;
    }
    elsif ($x >= 0 && $y < 0) {
        $angle = atan($y / $x) + 2*pi;
    }
    elsif ($x < 0 && $y < 0) {
        $angle = atan($y / $x) + pi;
    }
    $angle = sprintf('%.6f', $angle);
    die "$x,$y --> $angle" if $angle < 0;
    return $angle
}
