use strict;
use warnings;

use ExtUtils::MakeMaker;
use Module::CPANfile;

my $cpanfile = Module::CPANfile->load('cpanfile');
WriteMakefile(
    NAME         => 'Broker-Async',
    VERSION_FROM => 'lib/Broker/Async.pm',
    META_MERGE   => {
        'meta-spec' => { version => 2 },
        'prereqs'   => $cpanfile->prereq_specs,
    },
);

