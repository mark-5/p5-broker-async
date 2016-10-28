use strict;
use warnings;
use Broker::Async;
use Broker::Async::Worker;
use Future;
use List::Util qw( shuffle );
use Test::More;

subtest 'multi-worker concurrency' => sub {
    my %live;
    my $code = sub {
        my ($id)   = @_;
        return $live{$id} = Future->new->on_ready(sub{
            delete $live{$id};
        });
    };

    my $broker = Broker::Async->new(
        workers => [ ($code)x 2 ],
    );

    my @futures = map $broker->do($_), 1 .. 3;
    is_deeply [sort keys %live], [1, 2], 'broker doesnt concurrently run more tasks than number of workers';

    $live{1}->done;
    is_deeply [sort keys %live], [2, 3], 'broker runs another task after first resolves';
};

subtest 'order of execution' => sub {
    my $trace = {starts => [], live => []};
    my $code = sub {
        my ($id) = @_;
        my $future = Future->new;
        push @{ $trace->{starts} }, $id;
        push @{ $trace->{live} }, $future;
        return $future;
    };
    my @tasks = 1 .. 100;

    my $broker = Broker::Async->new(
        workers => [ ($code)x 10 ],
    );

    my @futures = map $broker->do($_), @tasks;
    while (my @live = @{ $trace->{live} }) {
        @{ $trace->{live} } = ();
        $_->done for shuffle @live;
    }

    is_deeply $trace->{starts}, \@tasks, 'broker starts tasks in the order they are seen';
};

subtest 'per worker concurrency' => sub {
    my %live;
    my $code = sub {
        my ($id)   = @_;
        return $live{$id} = Future->new->on_ready(sub{
            delete $live{$id};
        });
    };

    my $broker = Broker::Async->new(
        workers => [{code => $code, concurrency => 2}],
    );

    my @futures = map $broker->do($_), 1 .. 3;
    is_deeply [sort keys %live], [1, 2], 'broker respects worker concurrency limit';

    $live{1}->done;
    is_deeply [sort keys %live], [2, 3], 'broker runs another task after first resolves';
};

subtest 'worker constructor' => sub {
    subtest 'from code' => sub {
        my $code   = sub { Future->done };
        my $broker = Broker::Async->new(
            workers => [ $code ],
        );

        my $worker = $broker->workers->[0];
        is $worker->code, $code, 'worker uses code argument';
        is $worker->concurrency, 1, 'worker has default concurrency of 1';
    };

    subtest 'from hashref' => sub {
        my $code   = sub { Future->done };
        my $max    = 5;
        my $broker = Broker::Async->new(
            workers => [{code => $code, concurrency => $max}],
        );

        my $worker = $broker->workers->[0];
        is $worker->code, $code, 'worker uses code argument';
        is $worker->concurrency, $max, 'worker uses concurrency argument';
    };

    subtest 'from worker object' => sub {
        my $worker = Broker::Async::Worker->new(code => sub { Future->new });
        my $broker = Broker::Async->new(
            workers => [ $worker ],
        );
        is $broker->workers->[0], $worker, 'broker uses worker as is';
    };
};

done_testing;
