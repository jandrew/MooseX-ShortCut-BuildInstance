
use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "A shortcut to build Moose instances",
  "AUTHOR" => "Jed Lund <jandrew\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "MooseX-ShortCut-BuildInstance",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "MooseX::ShortCut::BuildInstance",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Data::Dumper" => 0,
    "Moose" => 0,
    "Moose::Exporter" => 0,
    "Moose::Meta::Class" => 0,
    "Moose::Util" => 0,
    "MooseX::Types::Moose" => 0,
    "Smart::Comments" => 0,
    "version" => "0.94"
  },
  "TEST_REQUIRES" => {
    "Capture::Tiny" => "0.12",
    "Modern::Perl" => 0,
    "Moose::Role" => 0,
    "MooseX::StrictConstructor" => 0,
    "Test::Moose" => 0,
    "Test::More" => 0,
    "Test::Most" => 0,
    "lib" => 0
  },
  "VERSION" => "v0.014.002",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Capture::Tiny" => "0.12",
  "Carp" => 0,
  "Data::Dumper" => 0,
  "Modern::Perl" => 0,
  "Moose" => 0,
  "Moose::Exporter" => 0,
  "Moose::Meta::Class" => 0,
  "Moose::Role" => 0,
  "Moose::Util" => 0,
  "MooseX::StrictConstructor" => 0,
  "MooseX::Types::Moose" => 0,
  "Smart::Comments" => 0,
  "Test::Moose" => 0,
  "Test::More" => 0,
  "Test::Most" => 0,
  "lib" => 0,
  "version" => "0.94"
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



