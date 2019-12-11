package Machine;

use strict;
use warnings;
use feature 'signatures';
no warnings 'experimental::signatures';

sub new($class, $program, $input, $output) {
    my $self = {
        memory => [ split /,/, $program ],
        i => 0,
        relative_base => 0,
        input => $input,
        output => $output,
        execution => 'run',
    };
    return bless $self, $class
}

sub run($self) {
    return if $self->{execution} eq 'halt';
    $self->{execution} = 'run';
    while ($self->{execution} eq 'run') {
        $self->run_instruction();
    }
}

sub run_instruction($self) {
    my $ops = {
        1 =>  [\&add, 3],
        2 =>  [\&mul, 3],
        3 =>  [\&input, 1],
        4 =>  [\&output, 1],
        5 =>  [\&jump_if_true, 2],
        6 =>  [\&jump_if_false, 2],
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

sub args($self, $number_of_args) {
    my $mode = int($self->{memory}[$self->{i}] / 100);
    my @args = ();
    for my $j (1 .. $number_of_args) {
        my $arg = $self->{memory}[$self->{i} + $j] // 0;
        my $m = $mode % 10;
        $mode = ($mode - $m) / 10;
        push @args, \($self->{memory}[$arg] //= 0)
            if $m == 0;
        push @args, \(my $tmp = $arg)
            if $m == 1;
        push @args, \($self->{memory}[$self->{relative_base} + $arg] //= 0)
            if $m == 2;
    }
    return \@args;
}

sub add($self, $x, $y, $z) {
    $$z = $$x + $$y;
    $self->{i} += 4
}

sub mul($self, $x, $y, $z) {
    $$z = $$x * $$y;
    $self->{i} += 4
}

sub input($self, $x) {
    if (@{$self->{input}} == 0) {
        $self->{execution} = 'block';
        return
    }
    $$x = shift @{$self->{input}};
    $self->{i} += 2;
}

sub output($self, $x) {
    push @{$self->{output}}, $$x;
    $self->{i} += 2;
}

sub jump_if_true($self, $x, $y) {
    $self->{i} = $$x ? $$y : $self->{i} + 3;
}

sub jump_if_false($self, $x, $y) {
    $self->{i} = !$$x ? $$y : $self->{i} + 3;
}

sub less_than($self, $x, $y, $z) {
    $$z = ($$x < $$y) ? 1 : 0;
    $self->{i} += 4
}

sub equals($self, $x, $y, $z) {
    $$z = ($$x == $$y) ? 1 : 0;
    $self->{i} += 4
}

sub relative_base_offset($self, $x) {
    $self->{relative_base} += $$x;
    $self->{i} += 2
}

sub halt($self) {
    $self->{execution} = 'halt';
}

1;
