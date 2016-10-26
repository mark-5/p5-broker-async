use strict;
use warnings;

package MyFuture;
use parent 'Future';

package main;
use Broker::Async;
use Future;
use Test::Fatal qw( dies_ok lives_ok );
use Test::More;

subtest 'arguments' => sub {
    my @args;
    my $adaptor = sub {
        @args = @_;
        return Future->new
    };
    
    my $broker = Broker::Async->new(
        adaptor => $adaptor,
        workers => [sub{ Future->new }],
    );
    my $f = $broker->do();

    is_deeply \@args, [$broker], 'adaptor is passed broker';
};

subtest 'return value' => sub {

    my %types = (
        future => {
            code  => sub { Future->new },
            happy => 1,
        },
        'future subclass' => {
            code  => sub { MyFuture->new },
            happy => 1,
        },
        'other ref' => {
            code  => sub { bless {}, 'NotAFuture' },
            happy => 0,
        },
    );

    my $create = sub {
        my ($adaptor) = @_;
        return Broker::Async->new(
            adaptor => $adaptor,
            workers => [sub{ Future->new }],
        );
    };

    for my $type (sort keys %types) {
        my $adaptor = $types{$type}{code};
        if ($types{$type}{happy}) {
            lives_ok { $create->($adaptor)->do } "adaptor can return $type";
        } else {
            dies_ok { $create->($adaptor)->do } "fatal error for adaptor returning $type";
        }
    }
};

subtest 'use' => sub {
    my $future;
    my $adaptor = sub {
        return $future = Future->new;
    };
    
    my $broker = Broker::Async->new(
        adaptor => $adaptor,
        workers => [sub{ Future->new }],
    );

    my $result = $broker->do();
    ok not($result->is_ready), 'broker result is not ready until adaptor acts on it';

    $future->done;
    ok $result->is_ready, 'broker result is ready when adaptor resolves the future';
};

done_testing;
