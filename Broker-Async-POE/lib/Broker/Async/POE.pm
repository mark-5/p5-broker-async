package Broker::Async::POE;
use strict;
use warnings;
use POE::Future;
use parent 'Broker::Async';

use Class::Tiny {
    adaptor => sub { sub { POE::Future->new } },
};

1;
