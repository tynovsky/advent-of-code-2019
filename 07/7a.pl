#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use Data::Dumper;

my $program = <DATA>;
chomp $program;

my $max = "-inf";
my $perm;
for my $p (perm(0,1,2,3,4)) {
    my $val = test_sequence($program, $p);
    if($val > $max) {
	$max = $val;
	$perm = $p;
    }

}
print @$perm;
say " => $max";

sub perm {
    my @elements = @_;
    my @out;
    return [$elements[0]] if @elements == 1;
    for my $i (0 .. $#elements) {
	my @rest = @elements[0 .. $i-1, $i+1 .. $#elements];
	for my $perm (perm(@rest)) {
	    push @out, [$elements[$i], @$perm]
	}
    }
    return @out
}

sub test_sequence {
    my ($program, $sequence) = @_;
    my @amplifier_input = (0);
    my $out;
    for my $phase_setting (@$sequence) {
	my $in = [$phase_setting, @amplifier_input];
	$out = run([ split /,/, $program ], $in);
	@amplifier_input = @$out;
    }
    return $out->[0];
}

sub run {
    my ($memory, $in) = @_;

    my $out = [];
    my $i = 0;
    while ($i > -1) {
        $i = run_instruction($memory, $i, $in, $out);
    }

    return $out
}

sub run_instruction {
    my ($memory, $i, $in, $out) = @_;
    my $ops = {
        1 => \&add,
        2 => \&mul,
	3 => \&input,
	4 => \&output,
	5 => \&jump_if_true,
	6 => \&jump_if_false,
	7 => \&less_than,
	8 => \&equals,
        99 => \&halt,
    };
    my $number_of_args_for = {
        1 => 2,
        2 => 2,
        3 => 0,
        4 => 1,
	5 => 2,
	6 => 2,
	7 => 2,
	8 => 2,
        99 => 0,
    };
    my $writes = {
	1 => 1,
	2 => 1,
	3 => 1,
	4 => 0,
	5 => 0,
	6 => 0,
	7 => 1,
	8 => 1,
	99 => 0,
    };

    my $opcode = opcode($memory, $i);
    my $op = $ops->{$opcode};
    my $number_of_args = $number_of_args_for->{$opcode};
    my $args = args($memory, $i, $number_of_args);
    my $write_address;
    if ($writes->{$opcode}) {
	$write_address = $memory->[$i + $number_of_args + 1];
    }
    # say join(',', @{$memory}[$i .. $i + $number_of_args + $writes->{$opcode}]);
    # say $memory->[$i], " ", $opcode, "(", join(',',@$args), ")";
    # if ($writes->{$opcode}) {
    #     say "\t--> ", $output_address;
    # }
    return $op->($memory, $i, $args, $write_address, $in, $out)
}

sub opcode {
    my ($memory, $i) = @_;
    return $memory->[$i] % 100;
}

sub args {
    my ($memory, $i, $number_of_args) = @_;
    my $opcode = opcode($memory, $i);
    my $mode = ($memory->[$i] - $opcode) / 100;
    my @mode = reverse(split(//, $mode)) if $mode;
    my @args = @{$memory}[($i + 1) .. ($i + $number_of_args)];
    for my $j (0 .. $#args) {
	$args[$j] = $memory->[$args[$j]] if ! $mode[$j]
    }
    return [@args];
}

sub write_address {
    my ($memory, $i, $index_offset) = @_;
    return if ! $index_offset;
    return $memory->[$i + $index_offset]
}

sub add {
    my ($memory, $i, $args, $write_address) = @_;
    $memory->[$write_address] = $args->[0] + $args->[1];
    return $i + 4
}

sub mul {
    my ($memory, $i, $args, $write_address) = @_;
    $memory->[$write_address] = $args->[0] * $args->[1];
    return $i + 4
}

sub input {
    my ($memory, $i, undef, $write_address, $in) = @_;
    $memory->[$write_address] = shift @$in;
    return $i + 2
}

sub output {
    my ($memory, $i, $args, undef, undef, $out) = @_;
    push @$out, $args->[0];
    # say "OUT: " . $args->[0];
    return $i + 2
}

sub jump_if_true {
    my ($memory, $i, $args) = @_;
    return $args->[1] if $args->[0];
    return $i + 3
}

sub jump_if_false {
    my ($memory, $i, $args) = @_;
    return $args->[1] if ! $args->[0];
    return $i + 3
}

sub less_than {
    my ($memory, $i, $args, $write_address) = @_;
    $memory->[$write_address] = ($args->[0] < $args->[1]) ? 1 : 0;
    return $i + 4
}

sub equals {
    my ($memory, $i, $args, $write_address) = @_;
    $memory->[$write_address] = ($args->[0] == $args->[1]) ? 1 : 0;
    return $i + 4
}

sub halt {
    return -1
}


__DATA__
3,8,1001,8,10,8,105,1,0,0,21,46,55,76,89,106,187,268,349,430,99999,3,9,101,4,9,9,1002,9,2,9,101,5,9,9,1002,9,2,9,101,2,9,9,4,9,99,3,9,1002,9,5,9,4,9,99,3,9,1001,9,2,9,1002,9,4,9,101,2,9,9,1002,9,3,9,4,9,99,3,9,1001,9,3,9,1002,9,2,9,4,9,99,3,9,1002,9,4,9,1001,9,4,9,102,5,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,101,1,9,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,99,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,99

3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0

3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0

3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0
