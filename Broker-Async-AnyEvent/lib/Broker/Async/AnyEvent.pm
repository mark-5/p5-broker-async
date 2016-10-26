package Broker::Async::AnyEvent;
use strict;
use warnings;
use AnyEvent::Future;
use parent 'Broker::Async';

our $VERSION = "0.0.1"; # version set by makefile

use Class::Tiny qw(), {
    adaptor => sub { sub{ AnyEvent::Future->new } },
};

1;
