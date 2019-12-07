package Machine;

use strict;
use warnings;
use Data::Dumper;

sub new {
    my ($class, $program, $input, $output) = @_;
    my $self = {
        memory => [ split /,/, $program ],
        i => 0,
        input => $input,
        output => $output,
	execution => 'run',
    };
    bless $self, $class
}


sub run {
    my ($self) = @_;
    return if $self->{execution} eq 'halt';
    $self->{execution} = 'run';
    while ($self->{execution} eq 'run') {
        $self->run_instruction();
    }
}

sub run_instruction {
    my ($self) = @_;
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

    my $opcode = $self->opcode();
    my $op = $ops->{$opcode};
    my $number_of_args = $number_of_args_for->{$opcode};
    my $args = $self->args($number_of_args);
    my $write_address;
    if ($writes->{$opcode}) {
	$write_address = $self->{memory}[$self->{i} + $number_of_args + 1];
    }
    return $op->($self, $args, $write_address)
}

sub read {
    my ($self, $i) = @_;
    $i //= $self->{i};
    return $self->{memory}[$i]
}

sub write {
    my ($self, $i, $val) = @_;
    $self->{memory}[$i] = $val;
}

sub opcode {
    my $self = shift;
    return $self->{memory}->[$self->{i}] % 100;
}

sub args {
    my ($self, $number_of_args) = @_;
    my $opcode = $self->opcode();
    my $mode = ($self->read() - $opcode) / 100;
    my @mode = reverse(split(//, $mode)) if $mode;
    my @args = @{$self->{memory}}[($self->{i} + 1) .. ($self->{i} + $number_of_args)];
    for my $j (0 .. $#args) {
	$args[$j] = $self->{memory}[$args[$j]] if ! $mode[$j]
    }
    return [@args];
}

sub write_address {
    my ($memory, $i, $index_offset) = @_;
    return if ! $index_offset;
    return $memory->[$i + $index_offset]
}

sub add {
    my ($self, $args, $write_address) = @_;
    $self->write($write_address, $args->[0] + $args->[1]);
    $self->{i} += 4
}

sub mul {
    my ($self, $args, $write_address) = @_;
    $self->write($write_address, $args->[0] * $args->[1]);
    $self->{i} += 4
}

sub input {
    my ($self, undef, $write_address) = @_;
    if (@{$self->{input}} == 0) {
	$self->{execution} = 'block';
	return
    }
    $self->write($write_address, shift @{$self->{input}});
    $self->{i} += 2;
}

sub output {
    my ($self, $args) = @_;
    push @{$self->{output}}, $args->[0];
    # say "OUT: " . $args->[0];
    $self->{i} += 2;
}

sub jump_if_true {
    my ($self, $args) = @_;
    if ($args->[0]) {
	$self->{i} = $args->[1];
    }
    else {
	$self->{i} += 3;
    }
}

sub jump_if_false {
    my ($self, $args) = @_;
    if (! $args->[0]) {
	$self->{i} = $args->[1]
    }
    else {
	$self->{i} += 3
    }
}

sub less_than {
    my ($self, $args, $write_address) = @_;
    $self->write($write_address, ($args->[0] < $args->[1]) ? 1 : 0);
    return $self->{i} += 4
}

sub equals {
    my ($self, $args, $write_address) = @_;
    $self->write($write_address, ($args->[0] == $args->[1]) ? 1 : 0);
    return $self->{i} += 4
}

sub halt {
    my ($self) = @_;
    $self->{execution} = 'halt';
}

1;
