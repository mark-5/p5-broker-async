use strict;
use warnings;
use AnyEvent::Future;
use Broker::Async;
use Test::More;

subtest 'basic' => sub {
    my $code   = sub { AnyEvent::Future->new_delay(after => 0) };
    my $broker = Broker::Async->new(
        workers => [ ($code)x 2 ],
    );

    my @futures = map $broker->do($_), 1 .. 5;
    is(
        scalar(grep { $_->is_ready } @futures),
        0,
        "no results ready immediately after queueing tasks",
    );

    $futures[-1]->get;
    is(
        scalar(grep { $_->is_ready } @futures),
        scalar(@futures),
        "all results ready after waiting for last result",
    );
};

done_testing;
