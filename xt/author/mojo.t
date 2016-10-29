use strict;
use warnings;
use Broker::Async;
use Future::Mojo;
use Mojo::IOLoop;
use Test::Broker::Async::Utils;
use Test::More;

subtest 'multi-worker concurrency' => sub {
    my $loop   = Mojo::IOLoop->singleton;
    my $code   = sub { Future::Mojo->new_timer($loop, 0) };
    my $broker = Broker::Async->new(
        workers => [ ($code)x 2 ],
    );

    test_event_loop($broker, [1 .. 5], 'mojo');
};

subtest 'per worker concurrency' => sub {
    my $loop   = Mojo::IOLoop->singleton;
    my $code   = sub { Future::Mojo->new_timer($loop, 0) };
    my $broker = Broker::Async->new(
        workers => [{code => $code, concurrency => 2}],
    );

    test_event_loop($broker, [1 .. 5], 'mojo');
};

done_testing;
