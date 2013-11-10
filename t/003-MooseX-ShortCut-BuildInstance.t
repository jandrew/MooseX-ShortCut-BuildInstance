#!perl
#######  Test File for MooseX::ShortCut::BuildInstance  #######
#~ BEGIN{
	#~ $ENV{ Smart_Comments } = '### #### #####';
#~ }

use Modern::Perl;

package main;

use Test::Most;
use Test::Moose;
if( $ENV{ Smart_Comments } ){
	use Smart::Comments -ENV;#'###'
	### Smart-Comments turned on for the Data-Walk-Print test ...
}
use Capture::Tiny 0.12 qw(
	capture_stderr
);
use lib '../lib', 'lib', 't';
use MooseX::ShortCut::BuildInstance 0.012;
my( 
			$pet_rock_class, $paco, $pacos_evil_twin, $pacos_good_twin, 
			$anonymous_class, $anonymous_instance,
);
my 			$test_case = 1;
my 			@class_attributes = qw(
			);
my  		@class_methods = qw(
			);
my  		@exported_methods = qw(
				build_class
				build_instance
				should_re_use_classes
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
				superclasses =>['Vegetable'],
				roles =>['Identity'],
			);
}										"Build a Pet::Rock class (with an Identity)";
does_ok		$pet_rock_class, 'Identity',"Ensure the Pet::Rock really does have an Identity";
is			$pet_rock_class->meta->name, 'Pet::Rock',
										"Make sure this is a Pet::Rock class";
lives_ok{
			$paco = $pet_rock_class->new(
				type_of_mineral => 'Quartz',
				name => 'Paco',
			);
}										'Get my own pet rock Paco';
is_deeply	[ $paco->meta->superclasses ], ['Vegetable'],
										"See if Paco is a Vegetable class (Not really right)";
			my $error_message = capture_stderr{
lives_ok{
			$pacos_evil_twin = build_instance(
				package => 'Pet::Rock',
				superclasses =>['Mineral'],
				roles =>['Identity'],
				type_of_mineral => 'Quartz',
				name => 'Fransisco',
			);
}										"Get Paco's doppleganger";
			};
like		$error_message, qr/^You already built the class: Pet::Rock/,
										"Check that a (correct) warning was issued for the overwritten class!";
is_deeply	[ $paco->meta->superclasses ], ['Mineral'],
										"See if Paco (not Fransisco) is a Mineral class now (dangerous magic!)";
lives_ok{	should_re_use_classes( 1 ) }
										"Set class re-use to on";
			$error_message = capture_stderr{
lives_ok{
			$pacos_good_twin = build_instance(
				package => 'Pet::Rock',
				superclasses =>['Mineral'],
				roles =>['Identity'],
				type_of_mineral => 'Quartz',
				name => 'Pancho',
			);
}										"Get Paco's doppleganger";
			};
is			$error_message, '',			"Check that no warning was issued for the overwritten class!";
does_ok		$pacos_good_twin, 'Identity',	"Ensure that Paco's twin really does have an Identity";
is			$pacos_good_twin->meta->name, 'Pet::Rock',
										"Make sure the twin is also a Pet::Rock class";
is_deeply	[ $paco->meta->superclasses ], ['Mineral'],
										"Make sure that Paco is a Mineral class";
is_deeply	[ $pacos_good_twin->meta->superclasses ], ['Mineral'],
										"Make sure that Pancho (Paco's twin) is also a Mineral class";
### <where> - $paco: $paco
is			$paco->name, 'Paco',	"Make sure Paco knows his name";
is			$pacos_good_twin->name, 'Pancho',"Make sure Pancho knows his name";
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
does_ok		$pet_rock_class, 'Identity',"Ensure the Individual really does have an Identity";
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
