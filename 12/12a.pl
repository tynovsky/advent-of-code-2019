#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use feature qw(say);

my $positions = [
    [6, 10, 10],
    [-9, 3, 17],
    [9, -4, 14],
    [4, 14, 4],
];

# my $positions = [
#     [-1, 0, 2],
#     [2, -10, -7],
#     [4, -8, 8],
#     [3, 5, -1],
# ];

my $velocities = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0],
];

for my $step (1 .. 1000) {
    say "Step " . ($step-1);
    for my $i (0 .. 3) {
        print_moon($positions->[$i], $velocities->[$i]);
    }
    apply_gravity($positions, $velocities);
    apply_velocity($positions, $velocities);
}



my $energy = 0;
for my $i (0 .. 3) {
    my $kin = sum(map { abs $_ } @{$positions->[$i]});
    my $pot = sum(map { abs $_ } @{$velocities->[$i]});
    say $kin, ", ", $pot;
    $energy += $kin * $pot
}

say $energy;

sub sum {
    my @items = @_;
    my $sum = 0;
    $sum += $_ for @items;
    return $sum
}

sub apply_gravity {
    my ($positions, $velocities) = @_;

    for my $i (0 .. 3) {
        for my $j ($i .. 3) {
            next if $i == $j;
            for my $k (0 .. 2) {
                if ($positions->[$i][$k] < $positions->[$j][$k]) {
                    $velocities->[$i][$k]++;
                    $velocities->[$j][$k]--;
                }
                elsif ($positions->[$i][$k] > $positions->[$j][$k]) {
                    $velocities->[$i][$k]--;
                    $velocities->[$j][$k]++;
                }
            }
        }
    }
}

sub apply_velocity {
    my ($positions, $velocities) = @_;

    for my $i (0 .. 3) {
        for my $k (0 .. 2) {
            $positions->[$i][$k] += $velocities->[$i][$k];
        }
    }
}

sub print_moon {
    my ($position, $velocity) = @_;

    printf("pos=<x=%3d, y=%3d, z=%3d>, vel=<x=%3d, y=%3d, z=%3d>\n", @$position, @$velocity);
}
