
use strict;
use warnings;

use 5.006;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "More tools for testing Moose packages",
  "AUTHOR" => "Chris Weyl <cweyl\@alumni.drew.edu>",
  "BUILD_REQUIRES" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Moose" => 0,
    "Moose::Role" => 0,
    "TAP::SimpleOutput" => 0,
    "Test::Builder::Tester" => 0,
    "Test::More" => "0.88",
    "namespace::autoclean" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Test-Moose-More",
  "EXE_FILES" => [],
  "LICENSE" => "lgpl",
  "NAME" => "Test::Moose::More",
  "PREREQ_PM" => {
    "Data::OptList" => 0,
    "Moose::Autobox" => 0,
    "Moose::Util" => 0,
    "Moose::Util::TypeConstraints" => 0,
    "Perl6::Junction" => 0,
    "Scalar::Util" => 0,
    "Sub::Exporter" => 0,
    "Test::Builder" => 0,
    "Test::Moose" => 0,
    "Test::More" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.017",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



