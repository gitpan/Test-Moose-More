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
  $Test::Moose::More::VERSION = '0.005';
}

# ABSTRACT: More tools for testing Moose packages

use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [ qw{
        has_method_ok is_role is_class
        check_sugar_ok check_sugar_removed_ok
        validate_class validate_role
        meta_ok does_ok
        with_immutable
    } ],
    groups  => { default => [ ':all' ] },
};

use Test::Builder;
use Test::More;
use Test::Moose 'with_immutable';
use Scalar::Util 'blessed';
use Moose::Util 'does_role', 'find_meta';

# debugging...
#use Smart::Comments;

my $tb = Test::Builder->new();

sub _thing_name {
    my ($thing, $thing_meta) = @_;
    $thing_meta ||= find_meta($thing);

    # try very hard to come up with a meaningful name
    my $desc
        = !!$thing_meta  ? $thing_meta->name
        : blessed $thing ? ref $thing
        : ref $thing     ? 'The object'
        :                  $thing
        ;

    return $desc;
}


sub meta_ok ($;$) {
    my ($thing, $message) = @_;

    my $thing_meta = find_meta($thing);
    $message ||= _thing_name($thing, $thing_meta) . ' has a meta';

    return $tb->ok(!!$thing_meta, $message);
}


sub does_ok {
    my ($thing, $roles, $message) = @_;

    my $thing_meta = find_meta($thing);

    $roles     = [ $roles ] unless ref $roles;
    $message ||= _thing_name($thing, $thing_meta) . ' does %s';

    $tb->ok(!!$thing_meta->does_role($_), sprintf($message, $_))
        for @$roles;

    return;
}


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

    return $tb->ok($meta->isa("Moose::Meta::$type"), "$thing_name is a Moose " . lc $type);
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



sub validate_thing {
    my ($class, %args) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    do { does_ok($class, $_) for @{$args{does}} }
        if exists $args{does};

    do { has_method_ok($class, $_) for @{$args{methods}} }
        if exists $args{methods};

    return;
}

sub validate_class {
    my ($class, @args) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return unless is_class $class;

    return validate_thing $class => @args;
}

sub validate_role {
    my ($class, @args) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return unless is_role $class;

    return validate_thing $class => @args;
}

!!42;



=pod

=encoding utf-8

=head1 NAME

Test::Moose::More - More tools for testing Moose packages

=head1 VERSION

version 0.005

=head1 SYNOPSIS

    use Test::Moose::More;

    is_class 'Some::Class';
    is_role  'Some::Role';
    has_method_ok 'Some::Class', 'foo';

    # ... etc

=head1 DESCRIPTION

This package contains a number of additional tests that can be employed
against Moose classes/roles.  It is intended to replace L<Test::Moose>.

=head1 FUNCTIONS

=head2 known_sugar

Returns a list of all the known standard Moose sugar (has, extends, etc).

=head1 TEST_FUNCTIONS

=head2 meta_ok $thing

Tests $thing to see if it has a metaclass; $thing may be the class name or
instance of the class you wish to check.

=head2 does_ok $thing, < $role | \@roles >, [ $message ]

Checks to see if $thing does the given roles.  $thing may be the class name or
instance of the class you wish to check.

Note that the message will be taken verbatim unless it contains C<%s>
somewhere; this will be replaced with the name of the role being tested for.

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

=head2 validate_class

validate_class {

    attributes => [ ... ],
    methods    => [ ... ],
    isa        => [ ... ],
    does       => [ ... ],

    requires_methods => [ ... ],

    meta => {
        class => {
            ...as above
        },
        attribute ... etc
    },
};

=head2 validate_role

The same as validate_class(), but for roles.

=head2 validate_thing

The same as validate_class() and validate_role(), except without the class or
role validation.

=head1 SEE ALSO

Please see those modules/websites for more information related to this module.

=over 4

=item *

L<Test::Moose>

=back

=head1 SOURCE

The development version is on github at L<http://github.com/RsrchBoy/test-moose-more>
and may be cloned from L<git://github.com/RsrchBoy/test-moose-more.git>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/RsrchBoy/test-moose-more/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Chris Weyl <cweyl@alumni.drew.edu>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Chris Weyl.

This is free software, licensed under:

  The GNU Lesser General Public License, Version 2.1, February 1999

=cut


__END__

