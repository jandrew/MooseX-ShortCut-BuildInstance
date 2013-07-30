#!perl
#######  Test File for MooseX::ShortCut::BuildInstance  #######
BEGIN{
	#~ $ENV{ Smart_Comments } = '### #### #####';
}

use Modern::Perl;

package main;

use Test::Most;
use Test::Moose;
if( $ENV{ Smart_Comments } ){
	use Smart::Comments -ENV;#'###'
	### Smart-Comments turned on for the Data-Walk-Print test ...
}
use lib '../lib', 'lib', 't';
use Mineral;
use Identity;
use MooseX::ShortCut::BuildInstance 0.005;
my( 
			$pet_rock_class, $paco, $pacos_twin, $anonymous_class, $anonymous_instance,
);
my 			$test_case = 1;
my 			@class_attributes = qw(
			);
my  		@class_methods = qw(
			);
my  		@exported_methods = qw(
				build_class
				build_instance
			);
my			$answer_ref = [
				'',#qr/The composed class passed to 'new' does not have either a 'before_method' or an 'after_method' the Role 'Data::Walk::Print' will be added/,
				[
					"undef,",
				],
			];
### <where> - easy questions
map{ 
has_attribute_ok
			'MooseX::ShortCut::BuildInstance', $_,
										"Check that Data::Walk::Extracted has the -$_- attribute"
} 			@class_attributes;
map{
can_ok		'MooseX::ShortCut::BuildInstance', $_,
} 			@class_methods;
map{
can_ok		'main', $_,
} 			@exported_methods;

### <where> - harder questions
lives_ok{
			$pet_rock_class = build_class(
				package => 'Pet::Rock',
				superclasses =>['Mineral'],
				roles =>['Identity'],
			);
}										"Build a Pet::Rock class (with an Identity)";
does_ok		$pet_rock_class, 'Identity',"Ensure the Pet::Rock realy does have an Identity";
is			$pet_rock_class->meta->name, 'Pet::Rock',
										"Make sure this is a Pet::Rock class";
lives_ok{
			$paco = $pet_rock_class->new(
				type_of_mineral => 'Quartz',
				name => 'Paco',
			);
}										'Get my own pet rock Paco';lives_ok{
			$pacos_twin = build_instance(
				package => 'Pet::Rock',
				superclasses =>['Mineral'],
				roles =>['Identity'],
				type_of_mineral => 'Quartz',
				name => 'Pancho',
			);
}										"Get Paco's doppleganger";
does_ok		$pacos_twin, 'Identity',	"Ensure that Paco's twin realy does have an Identity";
is			$pacos_twin->meta->name, 'Pet::Rock',
										"Make sure the twin is also a Pet::Rock class";
is_deeply	[ $paco->meta->superclasses ], ['Mineral'],
										"Make sure that Paco is a Mineral class";
is_deeply	[ $pacos_twin->meta->superclasses ], ['Mineral'],
										"Make sure that Pancho (Paco's twin) is also a Mineral class";
### <where> - $paco: $paco
is			$paco->name, 'Paco',	"Make sure Paco knows his name";
is			$pacos_twin->name, 'Pancho',"Make sure Pancho knows his name";
lives_ok{
			$anonymous_class = build_class(
				superclasses =>['Mineral'],
				roles =>['Identity'],
			);
}										"Build a Pet::Rock class (without the package name)";
like		$anonymous_class->meta->name, qr/^ANONYMOUS_SHIRAS_MOOSE_CLASS_\d*$/,
										"Make sure this is an Anonymous class";
lives_ok{
			$pet_rock_class = build_class(
				package => 'Individual',
				roles =>['Identity'],
				type_of_mineral => 'Quartz',
			);
}										"Build an Individual class (without a Mineral superclass)";
### <where> - pet rock class: $pet_rock_class->meta->linearized_isa
is			$pet_rock_class->meta->name, 'Individual',
										"Make sure this is an Individual class";
does_ok		$pet_rock_class, 'Identity',"Ensure the Individual realy does have an Identity";
### <where> - the isa: $pet_rock_class->isa( 'Mineral' )
ok			!$pet_rock_class->isa( 'Mineral'),
										"Check that the class (doesnt) have a 'Mineral' superclass";
ok			!$pet_rock_class->can( 'type_of_mineral' ),
										"Test that there is no 'type_of_mineral'";
lives_ok{
			$pet_rock_class = build_class(
				package => 'Rock',
				superclasses =>['Mineral'],
				type_of_mineral => 'Quartz',
			);
}										"Build a Rock class (without the Identity role)";
### <where> - pet rock class: $pet_rock_class->meta->linearized_isa
is			$pet_rock_class->meta->name, 'Rock',
										"Make sure this is a Rock class";
ok			!$pet_rock_class->DOES( 'Identity' ),
										"Ensure the Rock does not have an Identity";
### <where> - the isa: $pet_rock_class->isa( 'Mineral' )
ok			$pet_rock_class->isa( 'Mineral'),
										"Check that the class does have a 'Mineral' superclass";
ok			$pet_rock_class->can( 'type_of_mineral' ),
										"Test that there is a 'type_of_mineral'";
lives_ok{ 	$anonymous_instance = build_instance() }
										"Attempt an anonymous instance (without any superclass or role)";
explain 								"...Test Done";
done_testing();
