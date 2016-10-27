use strict;
use warnings;
use Broker::Async::POE;
use POE::Future;
use Test::Broker::Async qw(test_adaptor);
use Test::More;

use POE;
POE::Kernel->run;

subtest 'multi-worker concurrency' => sub {
    my $worker = sub{ POE::Future->new_delay(after => 0) };
    my $broker = Broker::Async::POE->new(
        workers => [ ($worker)x 2 ]
    );

    test_adaptor($broker, 1 .. 5);
};

subtest 'per worker concurrency' => sub {
    my $worker = sub{ POE::Future->new_delay(after => 0) };
    my $broker = Broker::Async::POE->new(
        workers => [{ code => $worker, concurrency => 2 }],
    );

    test_adaptor($broker, 1 .. 5);
};

done_testing;
