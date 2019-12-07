package Machine;

use strict;
use warnings;

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
    $self->{execution} = 'run'
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
