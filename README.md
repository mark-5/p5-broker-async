# NAME

Broker::Async - broker tasks for multiple workers

# SYNOPSIS

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

# DESCRIPTION

This module brokers asynchronous tasks for multiple workers. A worker can be any code reference that returns [Future](https://metacpan.org/pod/Future), representing work awaiting completion.

Some examples of common use cases might include throttling asynchronous requests to a server, or delegating tasks to a limited number of processes

If you are using a well known event loop, such as [AnyEvent](https://metacpan.org/pod/AnyEvent), [IO::Async](https://metacpan.org/pod/IO::Async), or [POE](https://metacpan.org/pod/POE), you will most likely want to use a dedicated subclass. See [Broker::Async::AnyEvent](https://metacpan.org/pod/Broker::Async::AnyEvent), [Broker::Async::IO::Async](https://metacpan.org/pod/Broker::Async::IO::Async), or [Broker::Async::POE](https://metacpan.org/pod/Broker::Async::POE).

# ATTRIBUTES

## engine

A code reference used for generating [Future](https://metacpan.org/pod/Future) objects.
Usually this is automatically set in [Broker::Async](https://metacpan.org/pod/Broker::Async) subclasses.

This is used to ensure an external event loop is active, while blocking on a future result.

## workers

An array ref of workers used for handling tasks.
Can be a code reference, a hash ref of [Broker::Async::Worker](https://metacpan.org/pod/Broker::Async::Worker) arguments, or a [Broker::Async::Worker](https://metacpan.org/pod/Broker::Async::Worker) object

Under the hood, code and hash references are simply used to instantiate a [Broker::Async::Worker](https://metacpan.org/pod/Broker::Async::Worker) object.
See [Broker::Async::Worker](https://metacpan.org/pod/Broker::Async::Worker) for more documentation about how these parameters are used.

# METHODS

## new

    my $broker = Broker::Async->new(
        engine => sub { ... },
        workers => [ sub { ... }, ... ],
    );

## available

    my @workers = $broker->available;

Returns an array of all available workers.

## do

    my $future = $broker->do($task);

Send a task to an available worker.
Returns a [Future](https://metacpan.org/pod/Future) object that resolves when the task is done.

There is no guarantee when a task will be started, that depends on when a worker becomes a available.
Tasks are guaranteed to be started in the order they are seen by $broker->do
