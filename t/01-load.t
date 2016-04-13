#!perl
### Test that the module(s) load!(s)
use	Test::More tests => 14 ;
use	Test::Requires "v5.10";
use Data::Dumper;
BEGIN{ use_ok( version ) };
BEGIN{ use_ok( Test::Moose ) };
BEGIN{ use_ok( Moose, 2.1213 ) };
BEGIN{ use_ok( Moose::Meta::Class ) };
BEGIN{ use_ok( Data::Dumper ) };
BEGIN{ use_ok( Carp, 'cluck' ) };
BEGIN{ use_ok( Moose::Exporter ) };
BEGIN{ $ENV{PERL_TYPE_TINY_XS} = 0; };
BEGIN{ use_ok( Type::Tiny, 1.000 ) };
BEGIN{ use_ok( Type::Utils, '-all' ) };
BEGIN{ use_ok( Types::Standard, '-types' ) };
BEGIN{ use_ok( Type::Library,
	'-base',
	'-declare' => qw(
		NameSpace
		SuperClassesList
		RolesList
		Attributes
		Methods
		BuildClassDict
	) ) };
use lib '../lib', 'lib',;
BEGIN{ use_ok( MooseX::ShortCut::BuildInstance::UnhideDebug, 1.038 ) };
BEGIN{ use_ok( MooseX::ShortCut::BuildInstance::Types, 1.038 ) };
BEGIN{ use_ok( MooseX::ShortCut::BuildInstance, 1.038 ) };
done_testing();