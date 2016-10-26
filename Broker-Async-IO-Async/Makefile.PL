use strict;
use warnings;

use ExtUtils::MakeMaker;
use Module::CPANfile;

my $cpanfile = Module::CPANfile->load('cpanfile');
my $prereqs  = $cpanfile->prereq_specs;
$prereqs->{runtime}{requires}{'Broker::Async'} = 0;

WriteMakefile(
    NAME         => 'Broker::Async::IO::Async',
    VERSION_FROM => 'lib/Broker/Async/IO/Async.pm',
    META_MERGE   => {
        'meta-spec' => { version => 2 },
        'prereqs'   => $prereqs,
    },
);

