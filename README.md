# NAME

Broker::Async - broker tasks for multiple workers

# SYNOPSIS
    my $scraper = sub {
        Future::HTTP->new->http_get(@_);
    };

    my $throttle = 5;
    my $broker = Broker::Async::AnyEvent->new(
        workers => [{code => $scraper, concurrency => $throttle}],
    );

    # asynchronously get 5 urls at a time
    my @results = map $broker->do($_), @urls;


    my @processes = map new_process(), 1 .. 5;
    my @workers   = map sub { my $proc = $_; sub{ $proc->request(@_) } } @processes;
    my $broker = Broker::Async::AnyEvent->new(workers => \@workers);

    # broker requests to a pool of 5 worker processes
    my @results = map $broker->do($_), @commands;
    
