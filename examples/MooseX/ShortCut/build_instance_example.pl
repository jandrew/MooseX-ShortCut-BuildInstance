#!/user/bin/env perl
package Mineral;
use Moose;
use Types::Standard qw( Enum );

has 'type' =>( 
		isa => Enum[qw( Quartz Diamond Basalt Granite )],
		is => 'ro' 
	);

package Identity;
use Moose::Role;

has 'name' =>( is => 'ro' );

use lib '../../../lib';
use MooseX::ShortCut::BuildInstance qw( should_re_use_classes build_instance );
should_re_use_classes( 1 );# To reuse build_instance
use Test::More;
use Test::Moose;

# First build of instance
my 	$paco = build_instance(
		package => 'Pet::Rock',
		superclasses =>['Mineral'],
		roles =>['Identity'],
		type => 'Quartz',
		name => 'Paco',
	);

does_ok( $paco, 'Identity', 'Check that the ' . $paco->meta->name . ' has an -Identity-' );
print'My ' . $paco->meta->name . ' made from -' . $paco->type . '- (a ' .
( join ', ', $paco->meta->superclasses ) . ') is called -' . $paco->name . "-\n";

# Next instance (If you don't want to call build_instance again)
my $Fransisco = Pet::Rock->new(
	type => 'Diamond',
	name => 'Fransisco',
);
does_ok( $Fransisco, 'Identity', 'Check that the ' . $Fransisco->meta->name . ' has an -Identity-' );
print'My ' . $Fransisco->meta->name . ' made from -' . $Fransisco->type . '- (a ' .
( join ', ', $Fransisco->meta->superclasses ) . ') is called -' . $Fransisco->name . "-\n";

# Another instance (reusing build_instance)
my $Gonzalo = build_instance(
		package => 'Pet::Rock',
		superclasses =>['Mineral'],
		roles =>['Identity'],
		type => 'Granite',
		name => 'Gonzalo',
	);
does_ok( $Gonzalo, 'Identity', 'Check that the ' . $Gonzalo->meta->name . ' has an -Identity-' );
print'My ' . $Gonzalo->meta->name . ' made from -' . $Gonzalo->type . '- (a ' .
( join ', ', $Gonzalo->meta->superclasses ) . ') is called -' . $Gonzalo->name . "-\n";
done_testing();