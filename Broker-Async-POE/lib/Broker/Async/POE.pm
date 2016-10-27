package Broker::Async::POE;
use strict;
use warnings;
use POE::Future;
use parent 'Broker::Async';

=head1 NAME

Broker::Async::POE - use Broker::Async with POE

=head1 SYNOPSIS

    my $broker = Broker::Async::POE->new(workers => \@workers);

=head1 DESCRIPTION

A subclass of L<Broker::Async> designed to work with L<POE>.
See L<Broker::Async> for documentation about how to use the broker.

=cut

our $VERSION = "0.0.1"; # version set by makefile

use Class::Tiny {
    engine => sub { sub { POE::Future->new } },
};

1;
