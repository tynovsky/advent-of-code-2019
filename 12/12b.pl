#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use feature qw(say);

# my $moons = [
#     {
#         position => [6, 10, 10],
#         velocity => [0, 0, 0],
#     },
#     {
#         position => [-9, 3, 17],
#         velocity => [0, 0, 0],
#     },
#     {
#         position => [9, -4, 14],
#         velocity => [0, 0, 0],
#     },
#     {
#         position => [4, 14, 4],
#         velocity => [0, 0, 0],
#     },
# ];

my $moons = [];
while (my $line = <>) {
    chomp $line;
    my ($x, $y, $z) = $line =~ /^<x=(.*?), y=(.*?), z=(.*?)>$/;
    push @$moons, {position =>[$x, $y, $z], velocity => [0, 0, 0]};
}

my $moons_orig = print_all($moons);
my $x_orig = $moons->[0]{position}[0];

my $step = 0;
while (1) {
    $step++;
    say $step if $step % 1000 == 0;
    apply_gravity($moons);
    apply_velocity($moons);
    next if $moons->[0]{position}[0] != $x_orig;
    last if print_all($moons) eq $moons_orig;
}

say "Last step " . $step;

sub apply_gravity {
    my ($moons) = @_;

    for my $i (0 .. 3) {
        for my $j ($i+1 .. 3) {
            attract($moons->[$i], $moons->[$j]);
        }
    }
}

sub attract {
    my ($m1, $m2) = @_;
    
    for my $k (1 .. 1) {
        if ($m1->{position}[$k] < $m2->{position}[$k]) {
            $m1->{velocity}[$k]++;
            $m2->{velocity}[$k]--;
        }
        elsif ($m1->{position}[$k] > $m2->{position}[$k]) {
            $m1->{velocity}[$k]--;
            $m2->{velocity}[$k]++;
        }
    }
}

sub apply_velocity {
    my ($moons) = @_;

    for my $i (0 .. 3) {
        for my $k (0 .. 2) {
            $moons->[$i]{position}[$k] += $moons->[$i]{velocity}[$k];
        }
    }
}

sub print_moon {
    my ($moon) = @_;

    return sprintf(
        "pos=<x=%3d, y=%3d, z=%3d>, vel=<x=%3d, y=%3d, z=%3d>",
        @{$moon->{position}},
        @{$moon->{velocity}},
    );
}

sub print_all {
    my ($moons) = @_;
    join("\n", map { print_moon($_) } @$moons)
}

__DATA__
