#!perl
#######  Test File for Data::Walk::Extracted  #######
BEGIN{
	#~ $ENV{ Smart_Comments } = '### #### #####';
}

use Modern::Perl;

package Mineral;
use Moose;

has 'type' =>( is => 'ro' );

package Identity;
use Moose::Role;

has 'name' =>( is => 'ro' );

package main;

use Test::Most;
use Test::Moose;
use lib '../lib', 'lib';
use MooseX::Util::ClassBuilder 0.001
		qw( build_class build_instance );
if( $ENV{ Smart_Comments } ){
	use Smart::Comments -ENV;#'###'
	### Smart-Comments turned on for the Data-Walk-Print test ...
}

my( 
			$pet_rock_class, $paco, $pacos_twin,
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
			'MooseX::Util::ClassBuilder', $_,
										"Check that Data::Walk::Extracted has the -$_- attribute"
} 			@class_attributes;
map{
can_ok		'MooseX::Util::ClassBuilder', $_,
} 			@class_methods;
map{
can_ok		'main', $_,
} 			@exported_methods;

### <where> - harder questions
lives_ok{
			$pet_rock_class = build_class(
				class_name => 'Pet::Rock',
				superclasses =>['Mineral'],
				roles =>['Identity'],
			);
}										"Build a Pet::Rock class (with an Identity)";
does_ok		$pet_rock_class, 'Identity',"Ensure the Pet::Rock realy does have an Identity";
is			$pet_rock_class->meta->name, 'Pet::Rock',
										"Make sure this is a Pet::Rock class";
lives_ok{
			$paco = $pet_rock_class->new(
				type => 'Quartz',
				name => 'Paco',
			);
}										'Get my own pet rock Paco';lives_ok{
			$pacos_twin = build_instance(
				class_name => 'Pet::Rock',
				superclasses =>['Mineral'],
				roles =>['Identity'],
				type => 'Quartz',
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
is			$paco->name, 'Paco',		"Make sure Paco knows his name";
is			$pacos_twin->name, 'Pancho',"Make sure Pancho knows his name";
explain 								"...Test Done";
done_testing();