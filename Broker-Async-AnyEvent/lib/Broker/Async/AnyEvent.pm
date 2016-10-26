package Broker::Async::AnyEvent;
use strict;
use warnings;
use AnyEvent::Future;
use parent 'Broker::Async';

use Class::Tiny qw(), {
    adaptor => sub { sub{ AnyEvent::Future->new } },
};

1;
