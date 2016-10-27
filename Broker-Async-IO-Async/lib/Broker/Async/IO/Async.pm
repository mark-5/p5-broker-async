package Broker::Async::IO::Async;
use strict;
use warnings;
use Carp;
use parent 'Broker::Async';

=head1 NAME

Broker::Async::IO::Async - use Broker::Async with IO::Async

=head1 SYNOPSIS

    my $loop   = IO::Async::Loop->new;
    my $broker = Broker::Async::IO::Async->new(
        loop    => $loop,
        workers => \@workers,
    );

=head1 DESCRIPTION

A subclass of L<Broker::Async> designed to work with L<IO::Async>.
See L<Broker::Async> for documentation about how to use the broker.

=head1 ATTRIBUTES

=head2 loop

The IO::Async::Loop used to generate futures.

=cut

our $VERSION = "0.0.1"; # version set by makefile

use Class::Tiny qw( loop ), {
    adaptor => sub { sub { shift->loop->new_future } },
};

sub BUILD {
    my ($self, @args) = @_;
    for my $name (qw( loop )) {
        croak "$name attribute required" unless defined $self->$name;
    }
}

1;
