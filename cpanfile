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
    requires 'Test::Fatal';
    requires 'Test::LeakTrace';
    requires 'Test::More';
};

on develop => sub {
    requires 'CPAN::Meta';
    requires 'Module::CPANfile';
    requires 'Pod::Markdown';
    requires 'Test::Pod', '1.00';
    requires 'Test::Strict';
};
