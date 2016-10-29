use strict;
use warnings;
use Broker::Async;
use IO::Async::Loop;
use Test::Broker::Async::Utils;
use Test::More;

subtest 'multi-worker concurrency' => sub {
    my $loop   = IO::Async::Loop->new;
    my $code   = sub { $loop->delay_future(after => 0) };
    my $broker = Broker::Async->new(
        workers => [ ($code)x 2 ],
    );

    test_event_loop($broker, [1 .. 5], 'io-async');
};

subtest 'per worker concurrency' => sub {
    my $loop   = IO::Async::Loop->new;
    my $code   = sub { $loop->delay_future(after => 0) };
    my $broker = Broker::Async->new(
        workers => [{code => $code, concurrency => 2}],
    );

    test_event_loop($broker, [1 .. 5], 'io-async');
};

done_testing;
