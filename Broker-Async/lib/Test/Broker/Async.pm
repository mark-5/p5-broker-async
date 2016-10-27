package Test::Broker::Async;
use strict;
use warnings;
use parent 'Exporter';
our @EXPORT_OK = qw(
    test_adaptor
);

=head1 NAME

Test::Broker::Async

=head1 DESCRIPTION

A testing library used for Broker::Async subclasses.

=head1 FUNCTIONS

=head2 test_adaptor

    my $success = test_adaptor($broker, \@tasks, 'my adaptor');

Tests that the adaptor used in $broker can move tasks through $broker's interal queue.

=cut

sub ready {
    my (@futures) = @_;
    my @ready = grep $_->is_ready, @futures;
    return scalar(@ready);
}

sub test_adaptor {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($broker, $tasks, $desc) = @_;
    $tasks = [1 .. 3] unless $tasks or @$tasks;
    $desc ||= '';
    my $failed = 0;

    my @futures = map $broker->do($_), @$tasks;
    Test::More::is(
        ready(@futures),
        0,
        ("$desc has no results ready immediately after queueing tasks")x!! $desc,
    ) or $failed++;

    $futures[-1]->get;
    Test::More::is(
        ready(@futures),
        scalar(@futures),
        ("$desc has all results ready after waiting for last result")x!! $desc,
    ) or $failed++;

    return not($failed);
}

1;
