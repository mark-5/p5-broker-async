package Broker::Async::IO::Async;
use strict;
use warnings;
use Carp;
use parent 'Broker::Async';

use Class::Tiny qw( loop ), {
    adaptor => sub { sub { shift->new_future } },
};

sub BUILD {
    my ($self, @args) = @_;
    for my $name (qw( loop )) {
        croak "$name attribute required" unless defined $self->$name;
    }
}

1;
