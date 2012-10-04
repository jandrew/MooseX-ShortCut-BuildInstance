
use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Yet another way to build Moose Classes",
  "AUTHOR" => "Jed Lund <jandrew\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Modern::Perl" => 0,
    "Moose::Role" => 0,
    "Test::Moose" => 0,
    "Test::More" => 0,
    "Test::Most" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "MooseX-Util-ClassBuilder",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "MooseX::Util::ClassBuilder",
  "PREREQ_PM" => {
    "Moose" => 0,
    "Moose::Exporter" => 0,
    "Moose::Meta::Class" => 0,
    "Smart::Comments" => 0,
    "version" => 0
  },
  "VERSION" => "v0.001_001",
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



