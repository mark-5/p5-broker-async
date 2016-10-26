#!/usr/bin/env perl
use Broker::Async::AnyEvent;
use Future;
use Future::HTTP;

my ($throttle, @urls) = @ARGV;

my $scraper = sub {
    Future::HTTP->new->http_get(@_);
};

my $broker = Broker::Async::AnyEvent->new(
    workers => [{code => $scraper, concurrency => $throttle}],
);

my @results;
for my $url (@urls) {
    push @results, $broker->do($url)->on_ready(sub{
        warn "> finished getting $url\n";
    });
}

Future->wait_all(@results)->get;
warn "> finished getting all results\n";
