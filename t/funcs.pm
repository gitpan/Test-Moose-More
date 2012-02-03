#
# This file is part of Test-Moose-More
#
# This software is Copyright (c) 2012 by Chris Weyl.
#
# This is free software, licensed under:
#
#   The GNU Lesser General Public License, Version 2.1, February 1999
#

# use as:
my ($_ok, $_nok) = counters();

sub counters {
    my $i = 1;
    return (
        sub {     'ok ' . $i++ . " - $_[0]" },
        sub { 'not ok ' . $i++ . " - $_[0]" },
    );
}

!!42;
