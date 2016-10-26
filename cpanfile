do $_ for glob "*/cpanfile";

on configure => sub {
    requires 'Carton';
};

on test => sub {
    requires 'Test::LeakTrace';
    requires 'Test::Pod', '1.00';
    requires 'Test::Strict';
};
