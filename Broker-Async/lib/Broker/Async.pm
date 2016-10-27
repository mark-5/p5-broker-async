package Broker::Async;
use strict;
use warnings;
use Broker::Async::Worker;
use Carp;
use Scalar::Util qw( blessed weaken );

=head1 NAME

Broker::Async - broker tasks for multiple workers

=head1 SYNOPSIS

    my @workers;
    for my $uri (@uris) {
        my $client = SomeClient->new($uri);
        push @workers, sub { $client->request(@_) };
    }

    my $broker = Broker::Async::AnyEvent->new(workers => \@clients);
    for my $future (map $broker->do($_), @requests) {
        my $result = $future->get;
        ...
    }

=head1 DESCRIPTION

This module brokers asynchronous tasks for multiple workers. A worker can be any code reference that returns L<Future>, representing work awaiting completion.

Some examples of common use cases might include throttling asynchronous requests to a server, or delegating tasks to a limited number of processes

If you are using a well known event loop, such as L<AnyEvent>, L<IO::Async>, or L<POE>, you will most likely want to use a dedicated subclass.

=cut

our $VERSION = "0.0.1"; # version set by makefile

=head1 ATTRIBUTES

=head2 engine

A code reference used for generating L<Future> objects.
Usually this is automatically set in L<Broker::Async> subclasses.

This is used to ensure an external event loop is active, while blocking on a future result.

=head2 workers

An array ref of workers used for handling tasks.
Can be a code reference, a hash ref of L<Broker::Async::Worker> arguments, or a L<Broker::Async::Worker> object

Under the hood, code and hash references are simply used to instantiate a L<Broker::Async::Worker> object.
See L<Broker::Async::Worker> for more documentation about how these parameters are used.

=cut

use Class::Tiny qw( engine workers ), {
    queue => sub {  [] },
};

=head1 METHODS

=head2 new

    my $broker = Broker::Async->new(
        engine => sub { ... },
        workers => [ sub { ... }, ... ],
    );

=head2 available

    my @workers = $broker->available;

Returns an array of all available workers.

=cut

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
    for my $name (qw( engine workers )) {
        croak "$name attribute required" unless defined $self->$name;
    }
}

=head2 do

    my $future = $broker->do($task);

Send a task to an available worker.
Returns a L<Future> object that resolves when the task is done.

There is no guarantee when a task will be started, that depends on when a worker becomes a available.
Tasks are guaranteed to be started in the order they are seen by $broker->do

=cut

sub do {
    my ($self, @args) = @_;
    my $f = $self->engine->($self);
    if (not( blessed($f) and $f->isa('Future') )) {
        croak "engine @{[ $self->engine ]} did not return a Future: returned $f";
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
