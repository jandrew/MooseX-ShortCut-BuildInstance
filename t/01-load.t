#!perl
### Test that the module(s) load!(s)
use	Test::More tests => 9;
use	Test::Requires "v5.10";
use Data::Dumper;
use lib '../lib', 'lib';
BEGIN{ use_ok( version ) };
BEGIN{ use_ok( Test::Moose ) };
BEGIN{ use_ok( Moose, 2.1213 ) };
BEGIN{ use_ok( Moose::Meta::Class ) };
BEGIN{ use_ok( Data::Dumper ) };
BEGIN{ use_ok( Carp, 'cluck' ) };
BEGIN{ use_ok( Moose::Exporter ) };
BEGIN{ use_ok( MooseX::ShortCut::BuildInstance::Types, 1.044 ) };
BEGIN{ use_ok( MooseX::ShortCut::BuildInstance, 1.044 ) };
done_testing();