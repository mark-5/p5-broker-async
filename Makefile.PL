use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Broker::Async',
    VERSION_FROM => 'lib/Broker/Async.pm',
    META_MERGE   => {
        'meta-spec' => { version => 2 },
        'prereqs'   => {
            'runtime' => {
                'requires' => {
                    'Carp'         => 0,
                    'Class::Tiny'  => 0,
                    'Exporter'     => 0,
                    'Scalar::Util' => 0,
                },
            },
            'test' => {
                'requires' => {
                    'Future'          => 0,
                    'Test::Fatal'     => 0,
                    'Test::LeakTrace' => 0,
                    'Test::More'      => 0,
                },
            },
            'develop' => {
                'requires' => {
                    'CPAN::Meta'       => 0,
                    'Module::CPANfile' => 0,
                    'Pod::Markdown'    => 0,
                    'Test::Pod'        => '1.00',
                    'Test::Strict'     => 0,
                },
            },
        },
    },
);

sub MY::postamble {
    return <<'__END__';

cpanfile: Makefile.PL
	perl -MCPAN::Meta -MModule::CPANfile -e 'Module::CPANfile->from_prereqs(CPAN::Meta->load_file("MYMETA.json")->prereqs)->save("cpanfile")'

readme: README.md

README.md: lib/Broker/Async.pm
	pod2markdown $< $@

__END__
}
