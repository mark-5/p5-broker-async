use strict;
use warnings;
use Broker::Async::IO::Async;
use IO::Async::Loop;
use Test::Broker::Async qw(test_adaptor);
use Test::More;

subtest 'multi-worker concurrency' => sub {
    my $loop = IO::Async::Loop->new;

    my $worker = sub{ $loop->delay_future(after => 0) };
    my $broker = Broker::Async::IO::Async->new(
        loop    => $loop,
        workers => [ ($worker)x 2 ]
    );

    test_adaptor($broker, [1 .. 5]);
};

subtest 'per worker concurrency' => sub {
    my $loop = IO::Async::Loop->new;

    my $worker = sub{ $loop->delay_future(after => 0) };
    my $broker = Broker::Async::IO::Async->new(
        loop    => $loop,
        workers => [{ code => $worker, concurrency => 2 }],
    );

    test_adaptor($broker, [1 .. 5]);
};

done_testing;
