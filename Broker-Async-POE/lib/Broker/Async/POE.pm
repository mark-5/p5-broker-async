package Broker::Async::POE;
use strict;
use warnings;
use POE::Future;
use parent 'Broker::Async';

our $VERSION = "0.0.1"; # version set by makefile

use Class::Tiny {
    adaptor => sub { sub { POE::Future->new } },
};

1;
