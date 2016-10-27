package Broker::Async::AnyEvent;
use strict;
use warnings;
use AnyEvent::Future;
use parent 'Broker::Async';

=head1 NAME

Broker::Async::AnyEvent - use Broker::Async with AnyEvent

=head1 SYNOPSIS

    my $broker = Broker::Async::AnyEvent->new(workers => \@workers);

=head1 DESCRIPTION

A subclass of L<Broker::Async> designed to work with L<AnyEvent>.
See L<Broker::Async> for documentation about how to use the broker.

=cut

our $VERSION = "0.0.1"; # version set by makefile

use Class::Tiny qw(), {
    engine => sub { sub{ AnyEvent::Future->new } },
};

1;
