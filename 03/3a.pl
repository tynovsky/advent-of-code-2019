#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use Data::Dumper;

my $line1 = <DATA>;
my $line2 = <DATA>;
chomp $line1;
chomp $line2;

my @line1 = split /,/, $line1;
my @line2 = split /,/, $line2;

my $start = [0, 0];

my $go = {
	D => sub { [$_[0]->[0], $_[0]->[1] - $_[1] }
	U => sub { [$_[0]->[0], $_[0]->[1] + $_[1] }
	L => sub { [$_[0]->[0] - $_[1], $_[0]->[1] }
	R => sub { [$_[0]->[0] + $_[1], $_[0]->[1] }
}

sub lines {
