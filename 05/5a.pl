#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use Data::Dumper;

sub run {
    my ($memory) = @_;

    my $instruction_pointer = 0;
    while (1) {
        say $instruction_pointer;
        my $instruction = get_instruction($memory, $instruction_pointer);
        my $halt = apply_instruction($memory, $instruction);
        last if $halt;
        $instruction_pointer += @$instruction;
    }
    
    return $memory->[0]
}

sub get_instruction {
    my ($memory, $instruction_pointer) = @_;
    my @indexes = ($instruction_pointer .. $instruction_pointer + 3);
    my $instruction = [ @{$memory}[@indexes] ];
    print Dumper $instruction;
    return $instruction
}

sub add {
    my ($memory, $a, $b, $c) = @_;
    $memory->[$c] = $memory->[$a] + $memory->[$b];
    return
}

sub mul {
    my ($memory, $a, $b, $c) = @_;
    $memory->[$c] = $memory->[$a] * $memory->[$b];
    return
}

sub halt {
    return 1
}

sub apply_instruction {
    my ($memory, $instruction) = @_;
    my $ops = {
        1 => \&add,
        2 => \&mul,
        99 => \&halt,
    };
    my ($opcode, @params) = @$instruction;
    return $ops->{$opcode}->($memory, @params)
}

my $program = <DATA>;
chomp $program;

my $memory = [ split /,/, $program ];

say run($memory);


__DATA__
1,9,10,3,2,3,11,0,99,30,40,50

1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,10,1,19,1,19,9,23,1,23,6,27,1,9,27,31,1,31,10,35,2,13,35,39,1,39,10,43,1,43,9,47,1,47,13,51,1,51,13,55,2,55,6,59,1,59,5,63,2,10,63,67,1,67,9,71,1,71,13,75,1,6,75,79,1,10,79,83,2,9,83,87,1,87,5,91,2,91,9,95,1,6,95,99,1,99,5,103,2,103,10,107,1,107,6,111,2,9,111,115,2,9,115,119,2,13,119,123,1,123,9,127,1,5,127,131,1,131,2,135,1,135,6,0,99,2,0,14,0
