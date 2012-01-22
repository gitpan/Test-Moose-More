#
# This file is part of Test-Moose-More
#
# This software is Copyright (c) 2012 by Chris Weyl.
#
# This is free software, licensed under:
#
#   The GNU Lesser General Public License, Version 2.1, February 1999
#
package Test::Moose::More;
{
  $Test::Moose::More::VERSION = '0.002';
}

# ABSTRACT: More tools for testing Moose packages

use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [ qw{
        has_method_ok is_role is_class
        check_sugar_ok check_sugar_removed_ok
    } ],
    groups  => { default => [ ':all' ] },
};
use Test::Builder;
use Test::More;
use Moose::Util 'does_role', 'find_meta';

# debugging...
#use Smart::Comments;

my $tb = Test::Builder->new();


sub has_method_ok {
    my ($thing, @methods) = @_;

    ### $thing
    my $meta = find_meta($thing);
    my $name = $meta->name;

    ### @methods
    $tb->ok(!!$meta->has_method($_), "$name has method $_") for @methods;
    return;
}


sub is_role  { unshift @_, 'Role';  goto \&_is_moosey }
sub is_class { unshift @_, 'Class'; goto \&_is_moosey }

sub _is_moosey {
    my ($type, $thing) =  @_;

    my $thing_name = ref $thing || $thing;

    my $meta = find_meta($thing);
    $tb->ok(!!$meta, "$thing_name has a metaclass");
    return unless !!$meta;

    $tb->ok($meta->isa("Moose::Meta::$type"), "$thing_name is a Moose " . lc $type);
    return;
}


sub known_sugar { qw{ has around augment inner before after blessed confess } }

sub check_sugar_removed_ok {
    my $t = shift @_;

    # check some (not all) Moose sugar to make sure it has been cleared
    #my @sugar = qw{ has around augment inner before after blessed confess };
    $tb->ok(!$t->can($_) => "$t cannot $_") for known_sugar;

    return;
}


sub check_sugar_ok {
    my $t = shift @_;

    # check some (not all) Moose sugar to make sure it has been cleared
    #my @sugar = qw{ has around augment inner before after blessed confess };
    $tb->ok($t->can($_) => "$t can $_") for known_sugar;

    return;
}

!!42;



=pod

=head1 NAME

Test::Moose::More - More tools for testing Moose packages

=head1 VERSION

version 0.002

=head1 SYNOPSIS

    use Test::Moose::More;

    is_class 'Some::Class';
    is_role  'Some::Role';
    has_method_ok 'Some::Class', 'foo';

    # ... etc

=head1 DESCRIPTION

This package contains a number of additional tests that can be employed
against Moose classes/roles.  It is intended to coexist with L<Test::Moose>,
though it does not (currently) require it.

=head1 TESTS

=head2 has_method_ok $thing, @methods

Queries $thing's metaclass to see if $thing has the methods named in @methods.

=head2 is_role $thing

Passes if $thing's metaclass isa L<Moose::Meta::Role>.

=head2 is_class $thing

Passes if $thing's metaclass isa L<Moose::Meta::Class>.

=head2 check_sugar_removed_ok $thing

Ensures that all the standard Moose sugar is no longer directly callable on a
given package.

=head2 check_sugar_ok $thing

Checks and makes sure a class/etc can still do all the standard Moose sugar.

=head1 FUNCTIONS

=head2 known_sugar

Returns a list of all the known standard Moose sugar (has, extends, etc).

=head1 SEE ALSO

L<Test::Moose>

=head1 BUGS

All complex software has bugs lurking in it, and this module is no exception.

Bugs, feature requests and pull requests through GitHub are most welcome; our
page and repo (same URI):

    https://github.com/RsrchBoy/test-moose-more

=head1 AUTHOR

Chris Weyl <cweyl@alumni.drew.edu>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Chris Weyl.

This is free software, licensed under:

  The GNU Lesser General Public License, Version 2.1, February 1999

=cut


__END__


