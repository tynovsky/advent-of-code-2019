package Machine;

use strict;
use warnings;
use Data::Dumper;

sub new {
    my ($class, $program, $input, $output) = @_;
    my $self = {
        memory => [ split /,/, $program ],
        relative_base => 0,
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
	9 => \&relative_base_offset,
        99 => \&halt,
    };
    my $number_of_args_for = {
        1 => 3,
        2 => 3,
        3 => 1,
        4 => 2,
        5 => 3,
        6 => 3,
        7 => 3,
        8 => 3,
	9 => 1,
        99 => 0,
    };

    my $opcode = $self->opcode();
    my $op = $ops->{$opcode};
    my $number_of_args = $number_of_args_for->{$opcode};
    my $args = $self->args($number_of_args);
    return $op->($self, @$args)
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
    my @args = ();
    for my $j (0 .. $number_of_args - 1) {
        my $arg = $self->{memory}[$self->{i} + $j + 1] // 0;
        if (!$mode[$j]) {
            push @args, \($self->{memory}[$arg]);
            next;
        }
        if ($mode[$j] == 1) {
            push @args, \(my $tmp = $arg);
            next;
        }
        if ($mode[$j] == 2) {
            push @args, \($self->{memory}[$self->{relative_base} + $arg]);
            next;
        }
    }
    return \@args;
}

sub write_address {
    my ($memory, $i, $index_offset) = @_;
    return if ! $index_offset;
    return $memory->[$i + $index_offset]
}

sub add {
    my ($self, $x, $y, $z) = @_;
    $$z = $$x + $$y;
    $self->{i} += 4
}

sub mul {
    my ($self, $x, $y, $z) = @_;
    $$z = $$x * $$y;
    $self->{i} += 4
}

sub input {
    my ($self, $x) = @_;
    if (@{$self->{input}} == 0) {
        $self->{execution} = 'block';
        return
    }
    $$x = shift @{$self->{input}};
    $self->{i} += 2;
}

sub output {
    my ($self, $x) = @_;
    push @{$self->{output}}, $$x;
    # say "OUT: " . $args->[0];
    $self->{i} += 2;
}

sub jump_if_true {
    my ($self, $x, $y) = @_;
    if ($$x) {
        $self->{i} = $$y;
    }
    else {
        $self->{i} += 3;
    }
}

sub jump_if_false {
    my ($self, $x, $y) = @_;
    if (! $$x) {
        $self->{i} = $$y;
    }
    else {
        $self->{i} += 3
    }
}

sub less_than {
    my ($self, $x, $y, $z) = @_;
    $$z = ($$x < $$y) ? 1 : 0;
    $self->{i} += 4
}

sub equals {
    my ($self, $x, $y, $z) = @_;
    $$z = ($$x == $$y) ? 1 : 0;
    $self->{i} += 4
}

sub relative_base_offset {
    my ($self, $x) = @_;
    $self->{relative_base} += $$x;
    $self->{i} += 2
}

sub halt {
    my ($self) = @_;
    $self->{execution} = 'halt';
}

1;
