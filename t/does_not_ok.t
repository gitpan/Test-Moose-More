use strict;
use warnings;

{ package TestRole::Role;   use Moose::Role;                                                }
{ package TestRole::Role2;  use Moose::Role;                                                }
{ package TestRole::Fail;   use Moose::Role; with 'TestRole::Role'; with 'TestRole::Role2'; }
{ package TestClass::Fail;  use Moose;       with 'TestRole::Role'; with 'TestRole::Role2'; }
{ package TestRole;         use Moose::Role;                                                }
{ package TestClass;        use Moose;                                                      }
{ package TestRole::Fail2;  use Moose::Role; with 'TestRole::Role';                         }
{ package TestClass::Fail2; use Moose;       with 'TestRole::Role';                         }

use Test::Builder::Tester;
use Test::More;
use Test::Moose::More;

require 't/funcs.pm' unless eval { require funcs };

my $ROLE  = 'TestRole::Role';
my @ROLES = qw{ TestRole::Role TestRole::Role2 };

note 'single role, default message - OK';
for my $thing (qw{ TestClass TestRole }) {
    my ($_ok, $_nok) = counters();
    test_out $_ok->("$thing does not do $ROLE");
    does_not_ok $thing, $ROLE;
    test_test "$thing is found to not do $ROLE correctly";
}

note 'single role, custom message - OK';
for my $thing (qw{ TestClass TestRole }) {
    my ($_ok, $_nok) = counters();
    test_out $_ok->('wah-wah');
    does_not_ok $thing, $ROLE, 'wah-wah';
    test_test "$thing: custom messages work as expected";
}

note 'single role, "complex" custom message - OK';
for my $thing (qw{ TestClass TestRole }) {
    my ($_ok, $_nok) = counters();
    test_out $_ok->("wah-wah $ROLE");
    does_not_ok $thing, $ROLE, 'wah-wah %s';
    test_test "$thing: 'complex' custom messages work as expected";
}

note 'multiple roles, default message - OK';
for my $thing (qw{ TestClass TestRole }) {
    # role - OK
    my ($_ok, $_nok) = counters();
    test_out $_ok->("$thing does not do $_") for @ROLES;
    does_not_ok $thing, [ @ROLES ];
    test_test "$thing is found to not do the roles correctly";
}

note 'multiple roles, custom message - OK';
for my $thing (qw{ TestClass TestRole }) {
    # role - OK
    my ($_ok, $_nok) = counters();
    my $msg = 'wah-wah';
    test_out $_ok->($msg) for @ROLES;
    does_not_ok $thing, [ @ROLES ], $msg;
    test_test "$thing: multiple roles, custom messages work as expected";
}

note 'multiple roles, "complex" custom message - OK';
for my $thing (qw{ TestClass TestRole }) {
    # role - OK
    my ($_ok, $_nok) = counters();
    my $msg = 'wah-wah';
    test_out $_ok->("$msg $_") for @ROLES;
    does_not_ok $thing, [ @ROLES ], "$msg %s";
    test_test "$thing: multiple roles, 'complex' custom messages work as expected";
}

note 'role - NOT OK';
for my $thing (qw{ TestClass::Fail TestRole::Fail }) {
    # role - NOT OK
    my ($_ok, $_nok) = counters();
    test_out $_nok->("$thing does not do $ROLE");
    test_fail 1;
    does_not_ok $thing, $ROLE;
    test_test "$thing is found to not do $ROLE correctly";
}

note 'multiple roles - NOT OK';
for my $thing (qw{ TestClass::Fail TestRole::Fail }) {
    # role - OK
    my ($_ok, $_nok) = counters();
    do { test_out $_nok->("$thing does not do $_"); test_fail 1 } for @ROLES;
    does_not_ok $thing, [ @ROLES ];
    test_test "$thing: multiple roles fail as expected";
}

note 'multiple roles - PARTIALLY OK';
for my $thing (qw{ TestClass::Fail2 TestRole::Fail2 }) {
    # role - OK
    my ($_ok, $_nok) = counters();
    do { test_out $_nok->("$thing does not do $_"); test_fail 2 } for $ROLES[0];
    do { test_out $_ok->("$thing does not do $_")               } for $ROLES[1];
    does_not_ok $thing, [ @ROLES ];
    test_test "$thing: multiple roles partially fail as expected";
}

done_testing;
