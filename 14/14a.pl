#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use feature qw(say);
use POSIX qw(ceil);

my $reactions = {};
while (my $line = <>) {
    my ($input, $output) = $line =~ /(.*) => (.*)/;
    my @input = map { [split / /, $_] } split(/, /, $input);
    my ($units, $chemical) = split / /, $output;

    $reactions->{$chemical} = {};
    $reactions->{$chemical}{inputs} = \@input;
    $reactions->{$chemical}{units} = $units;
}

say ore_units_required($reactions, 'FUEL', 1, {});

sub ore_units_required {
    my ($reactions, $output, $wanted_units, $stock) = @_;

    my $inputs = $reactions->{$output}{inputs};
    my $created_units = $reactions->{$output}{units};
    $stock->{$output} //= 0;
    say "$output: wanted $wanted_units, on stock $stock->{$output}";
    $wanted_units -= $stock->{$output};
    say "$output: will create $wanted_units";
    $stock->{$output} = 0;
    my $multiplier = ceil($wanted_units / $created_units);
    my $remainder = $multiplier * $created_units - $wanted_units;
    say "$output: will run the reaction $multiplier times";
    say "$output: $remainder units will remain";
    print "\n";

    my $ore_units = 0;
    for my $input (@$inputs) {
        if($input->[1] eq 'ORE') {
            $ore_units += $multiplier * $input->[0];
            next
        }
        $ore_units += ore_units_required($reactions, $input->[1], $multiplier * $input->[0], $stock);
    }
    $stock->{$output} = $remainder;
    return $ore_units
}
