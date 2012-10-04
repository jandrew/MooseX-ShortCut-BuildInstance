#!perl
BEGIN{
	#~ $ENV{ Smart_Comments } = '###';
}
use Modern::Perl;

package Mineral;
use Moose;

has 'type' =>( is => 'ro' );

package Identity;
use Moose::Role;

has 'name' =>( is => 'ro' );

use lib '../lib';
use MooseX::Util::ClassBuilder qw( build_class );
use Test::More;
use Test::Moose;

my 	$pet_rock_class = build_class(
		class_name => 'Pet::Rock',
		superclasses =>['Mineral'],
		roles =>['Identity'],
	);

my 	$paco = $pet_rock_class->new(
		type => 'Quartz',
		name => 'Paco',
	);

does_ok( $paco, 'Identity', 'Check that the ' . $paco->meta->name . ' has an -Identity-' );
say 'My ' . $paco->meta->name . ' made from -' . $paco->type . '- (a ' .
( join ', ', $paco->meta->superclasses ) . ') is called -' . $paco->name . '-';
done_testing();