package Test::Broker::Async;
use strict;
use warnings;
use parent 'Exporter';
our @EXPORT_OK = qw(
    test_adaptor
);

sub ready {
    my (@futures) = @_;
    my @ready = grep $_->is_ready, @futures;
    return scalar(@ready);
}

sub test_adaptor {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($broker, @tasks) = @_;
    @tasks = (1 .. 3) unless @tasks;

    my @futures = map $broker->do($_), @tasks;
    Test::More::is(
        ready(@futures),
        0,
        "no results ready immediately after queueing",
    );

    $futures[-1]->get;
    Test::More::is(
        ready(@futures),
        scalar(@futures),
        "all results ready after waiting for last result",
    );
}

1;
