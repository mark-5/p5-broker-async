use strict;
use warnings;
use Broker::Async;
use IO::Async::Loop;
use Test::More;

subtest 'basic' => sub {
    my $loop   = IO::Async::Loop->new;
    my $code   = sub { $loop->delay_future(after => 0) };
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