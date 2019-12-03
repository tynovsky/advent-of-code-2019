#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use Data::Dumper;

my $input = <DATA>;
chomp $input;

my @program = split /,/, $input;

for my $noun (0..100) {
    for my $verb ($0 .. 100) {
        say((100 * $noun + $verb) . " => " . run(\@program, $noun, $verb))
    }
}

sub run {
    my ($program, $noun, $verb) = @_;
    my @program = @$program;
    $program[1] = $noun;
    $program[2] = $verb;

    for my $i (0 .. $#program) {
        next if $i % 4 != 0;
        # say Dumper \@program;
        last if $program[$i] == 99;
        if ($program[$i] == 1) {
            $program[$program[$i + 3]] = $program[$program[$i + 1]] + $program[$program[$i + 2]]
        }
        if ($program[$i] == 2) {
            $program[$program[$i + 3]] = $program[$program[$i + 1]] * $program[$program[$i + 2]]
        }
    }
    return $program[0]
}

# say $program[0];


__DATA__
1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,10,1,19,1,19,9,23,1,23,6,27,1,9,27,31,1,31,10,35,2,13,35,39,1,39,10,43,1,43,9,47,1,47,13,51,1,51,13,55,2,55,6,59,1,59,5,63,2,10,63,67,1,67,9,71,1,71,13,75,1,6,75,79,1,10,79,83,2,9,83,87,1,87,5,91,2,91,9,95,1,6,95,99,1,99,5,103,2,103,10,107,1,107,6,111,2,9,111,115,2,9,115,119,2,13,119,123,1,123,9,127,1,5,127,131,1,131,2,135,1,135,6,0,99,2,0,14,0
