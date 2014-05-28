#!perl
### Test that the module(s) load!(s)
use	Test::More;
BEGIN{ use_ok( version ) };
BEGIN{ use_ok( Test::Moose ) };
BEGIN{ use_ok( Data::Dumper ) };
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
BEGIN{ use_ok( MooseX::ShortCut::BuildInstance::Types, 1.002 ) };
BEGIN{ use_ok( MooseX::ShortCut::BuildInstance, 1.002 ) };
done_testing();