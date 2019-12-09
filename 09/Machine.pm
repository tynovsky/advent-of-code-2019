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
        1 =>  [\&add, 3],
        2 =>  [\&mul, 3],
        3 =>  [\&input, 1],
        4 =>  [\&output, 2],
        5 =>  [\&jump_if_true, 3],
        6 =>  [\&jump_if_false, 3],
        7 =>  [\&less_than, 3],
        8 =>  [\&equals, 3],
	9 =>  [\&relative_base_offset, 1],
        99 => [\&halt, 0],
    };

    my $opcode = $self->{memory}->[$self->{i}] % 100;
    my ($op, $number_of_args) = @{ $ops->{$opcode} };
    my $args = $self->args($number_of_args);
    return $op->($self, @$args)
}

sub args {
    my ($self, $number_of_args) = @_;
    my $mode = int($self->{memory}[$self->{i}] / 100);
    my @args = ();
    for my $j (0 .. $number_of_args - 1) {
        my $arg = $self->{memory}[$self->{i} + $j + 1] // 0;
        my $m = $mode % 10;
        $mode = ($mode - $m) / 10;
        if (!$m) {
            push @args, \($self->{memory}[$arg]);
            next;
        }
        if ($m == 1) {
            push @args, \(my $tmp = $arg);
            next;
        }
        if ($m == 2) {
            push @args, \($self->{memory}[$self->{relative_base} + $arg]);
            next;
        }
    }
    return \@args;
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
