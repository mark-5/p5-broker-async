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
    my $engine = sub {
        @args = @_;
        return Future->new
    };
    
    my $broker = Broker::Async->new(
        engine  => $engine,
        workers => [sub{ Future->new }],
    );
    my $f = $broker->do();

    is_deeply \@args, [$broker], 'engine is passed broker';
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
        my ($engine) = @_;
        return Broker::Async->new(
            engine  => $engine,
            workers => [sub{ Future->new }],
        );
    };

    for my $type (sort keys %types) {
        my $engine = $types{$type}{code};
        if ($types{$type}{happy}) {
            lives_ok { $create->($engine)->do } "engine can return $type";
        } else {
            dies_ok { $create->($engine)->do } "fatal error for engine returning $type";
        }
    }
};

subtest 'use' => sub {
    my $future;
    my $engine = sub {
        return $future = Future->new;
    };
    
    my $broker = Broker::Async->new(
        engine  => $engine,
        workers => [sub{ Future->new }],
    );

    my $result = $broker->do();
    ok not($result->is_ready), 'broker result is not ready until engine acts on it';

    $future->done;
    ok $result->is_ready, 'broker result is ready when engine resolves the future';
};

done_testing;
