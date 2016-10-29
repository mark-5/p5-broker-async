use strict;
use warnings;
use ExtUtils::MakeMaker;

my $main = 'lib/Broker/Async.pm';
WriteMakefile(
    NAME          => 'Broker::Async',
    AUTHOR        => [ 'Mark Flickinger <maf@cpan.org>' ],
    ABSTRACT_FROM => $main,
    VERSION       => '0.0.1',
    test          => { RECURSIVE_TEST_FILES => 1 },
    META_MERGE    => {
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
                    'parent'          => 0,
                    'Future'          => 0,
                    'List::Util'      => 0,
                    'Test::Fatal'     => 0,
                    'Test::LeakTrace' => 0,
                    'Test::More'      => 0,
                },
            },
            'develop' => {
                'requires' => {
                    'AnyEvent::Future' => 0,
                    'AnyEvent::HTTP'   => 0,
                    'CPAN::Meta'       => 0,
                    'Future::HTTP'     => 0,
                    'Future::Mojo'     => 0,
                    'IO::Async'        => 0,
                    'Module::CPANfile' => 0,
                    'Mojolicious'      => 0,
                    'Pod::Markdown'    => 0,
                    'POE::Future'      => 0,
                    'Test::Pod'        => '1.00',
                    'Test::Strict'     => 0,
                },
            },
        },
        'resources' => {
            'bugtracker' => {'web' => 'https://github.com/mark-5/p5-broker-async/issues'},
            'homepage'   => 'https://github.com/mark-5/p5-broker-async',
            'repository' => {
                'type' => 'git',
                'url'  => 'https://github.com/mark-5/p5-broker-async.git',
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

version:
	perl -pi -e 's/(.*)(# __VERSION__)/our \$$VERSION = "$(VERSION)"; $$2/g' `find lib -name '*.pm'`

__END__
}

sub MY::test_via_harness {
    my ($self, $perl, @tests) = @_;
    return $self->MM::test_via_harness("$perl -It/lib", @tests);
}
