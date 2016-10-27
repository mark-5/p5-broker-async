use strict;
use warnings;
use AnyEvent::Future;
use Broker::Async::AnyEvent;
use Test::Broker::Async qw(test_adaptor);
use Test::More;

subtest 'multi-worker concurrency' => sub {
    my $worker = sub{ AnyEvent::Future->new_delay(after => 0) };
    my $broker = Broker::Async::AnyEvent->new(
        workers => [ ($worker)x 2 ]
    );

    test_adaptor($broker, 1 .. 5);
};

subtest 'per worker concurrency' => sub {
    my $worker = sub{ AnyEvent::Future->new_delay(after => 0) };
    my $broker = Broker::Async::AnyEvent->new(
        workers => [{ code => $worker, concurrency => 2 }],
    );

    test_adaptor($broker, 1 .. 5);
};

done_testing;
