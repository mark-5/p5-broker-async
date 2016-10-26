package Broker::Async;
use strict;
use warnings;
use Broker::Async::Worker;
use Carp;
use Scalar::Util qw( blessed weaken );

our $VERSION = "0.0.1"; # version set by makefile

use Class::Tiny qw( adaptor workers ), {
    queue => sub {  [] },
};

sub available {
    my ($self) = @_;
    return grep { $_->available } @{ $self->workers };
}

sub BUILDARGS {
    my $class = shift;

    my $args;
    if (@_ == 1 and ref($_[0]) eq 'HASH') {
        $args = { %{ $_[0] } };
    } else {
        $args = { @_ }
    }

    if (my $workers = $args->{workers}) {
        croak "workers attribute must be an array ref: received $workers"
            unless ref($workers) eq 'ARRAY';
        $args->{workers} = $workers = [ @$workers ];

        for (my $i = 0; $i < @$workers; $i++) {
            my $worker = $workers->[$i];

            my $type = ref($worker);
            if ($type eq 'CODE') {
                $workers->[$i] = Broker::Async::Worker->new({code => $worker});
            } elsif ($type eq 'HASH') {
                $workers->[$i] = Broker::Async::Worker->new($worker);
            }
        }
    }

    return $args;
}

sub BUILD {
    my ($self) = @_;
    for my $name (qw( adaptor workers )) {
        croak "$name attribute required" unless defined $self->$name;
    }
}

sub do {
    my ($self, @args) = @_;
    my $f = $self->adaptor->($self);
    if (not( blessed($f) and $f->isa('Future') )) {
        croak "adaptor @{[ $self->adaptor ]} did not return a Future: returned $f";
    }

    push @{ $self->queue }, {args => \@args, future => $f};
    $self->process_queue;

    return $f;
}

sub process_queue {
    weaken(my $self = shift);
    my $queue = $self->queue;

    while (@$queue) {
        my ($worker) = $self->available or last;
        my $task     = shift @$queue;

        my $f = $worker->do(@{ $task->{args} });
        $f->on_ready($task->{future});
        $f->on_ready(sub{ $self->process_queue });
    }
}

1;
