package Broker::Async::Worker;
use strict;
use warnings;
use Carp;
use Scalar::Util qw( blessed weaken );

use Class::Tiny qw( code ), {
    concurrency => sub { 1 },
    futures     => sub { +{} },
    available   => sub { shift->concurrency },
};

sub do {
    weaken(my $self = shift);
    my ($done, @args) = @_;
    if (not( $self->available )) {
        croak "worker $self is not available for work";
    }

    my $f = $self->code->(@args);
    if (not( blessed($f) and $f->isa('Future') )) {
        croak "code for worker $self did not return a Future: returned $f";
    }

    $f->on_ready($done);
    $self->available( $self->available - 1 );

    return $self->futures->{$f} = $f->on_ready(sub{
        delete $self->futures->{$f};
        $self->available( $self->available + 1 );
    });
}

1;
