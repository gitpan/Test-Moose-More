use strict;
use warnings;

use Test::Builder::Tester;
use Moose::Util 'with_traits';
use Test::More;
use Test::Moose::More;
use TAP::SimpleOutput 'counters';

{ package TestRole; use Moose::Role; use namespace::autoclean; }
{ package TestClass; use Moose; }

# initial tests, covering the most straight-forward cases (IMHO)

my $anon_class = with_traits('TestClass' => 'TestRole');
my $anon_role  = Moose::Meta::Role
    ->create_anon_role(weaken => 0)
    ->name
    ;

note 'simple anon class';
{
    my ($_ok, $_nok, $_skip) = counters();
    test_out $_ok->("$anon_class is anonymous");
    is_anon $anon_class;
    test_test 'is_anon works correctly on anon class';
}

note 'simple anon role';
{
    my ($_ok, $_nok, $_skip) = counters();
    test_out $_ok->("$anon_role is anonymous");
    is_anon $anon_role;
    test_test 'is_anon works correctly on anon role';
}

note 'simple !anon class';
{
    my ($_ok, $_nok, $_skip) = counters();
    test_out $_nok->('TestClass is anonymous');
    test_fail 1;
    is_anon 'TestClass';
    test_test 'is_anon works correctly on !anon class';
}

note 'simple !anon role';
{
    my ($_ok, $_nok, $_skip) = counters();
    test_out $_nok->('TestRole is anonymous');
    test_fail 1;
    is_anon 'TestRole';
    test_test 'is_anon works correctly on !anon role';
}

done_testing;
