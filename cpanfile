requires 'Carp';
requires 'Class::Tiny';
requires 'Exporter';
requires 'Scalar::Util';

on configure => sub {
    requires 'ExtUtils::MakeMaker';
};

on build => sub {
    requires 'ExtUtils::MakeMaker';
};

on test => sub {
    requires 'Future';
    requires 'List::Util';
    requires 'Test::Fatal';
    requires 'Test::LeakTrace';
    requires 'Test::More';
    requires 'parent';
};

on develop => sub {
    requires 'AnyEvent::Future';
    requires 'CPAN::Meta';
    requires 'IO::Async';
    requires 'Module::CPANfile';
    requires 'POE::Future';
    requires 'Pod::Markdown';
    requires 'Test::Pod', '1.00';
    requires 'Test::Strict';
};
