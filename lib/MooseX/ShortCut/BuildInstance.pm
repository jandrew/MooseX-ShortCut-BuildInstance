package MooseX::ShortCut::BuildInstance;
use 5.010;
use Carp;
use Moose;
use Moose::Meta::Class;
use version; our $VERSION = qv('0.003_003');
use Moose::Exporter;
Moose::Exporter->setup_import_methods(
	as_is => [ 'build_instance', 'build_class' ],
);

BEGIN{
	if( $ENV{ Smart_Comments } ){
		use Smart::Comments -ENV;
		### Smart-Comments turned on for MooseX-Util-ClassBuilder ...
	}
}

###############  Package Variables  #####################################################

our	$instance_count //= 1;
my 	@class_args = qw(
		package
		superclasses
		roles
	);

###############  Dispatch Tables  #######################################################

###############  Public Attributes  #####################################################

###############  Public Methods  ########################################################

sub build_class{
	### <where> - reached build_class ...
	##### <where> - passed arguments: @_
	my	$args = ( scalar( @_ ) == 1 ) ? $_[0] : { @_ };
	my ( $class_args, $i, $can_build );
	for my $key ( @class_args ){
		if( exists $args->{$key} ){
			$class_args->{$key} = $args->{$key};
			delete $args->{$key};
		}
		##### <where> - class args are: $class_args
		### <where> - position: $i
		### <where> - position exists: $class_args->{$key}
		if( !$class_args->{$key} and !$i ){# package only
			### <where> - missing a package value ...
			$class_args->{package} = "ANONYMOUS_SHIRAS_MOOSE_CLASS_" . $instance_count++;
		}elsif( $class_args->{$key} ){
			$can_build++;
		}
		$i++
	}
	if( !$can_build ){
		confess "No class or role sent to build the new class!!";
	}
	my $want_array = ( caller(0) )[5];
	### <where> - class args: $class_args
	### <where> - remaining arguments: $args
	### <where> - want array: $want_array
	my 	$class_name = Moose::Meta::Class->create( %{$class_args} )->name;
	### <where> - returning the name: $class_name
	if( $want_array ){
		return ( $class_name, $args );
	}else{
		return $class_name;
	}
}

sub build_instance{
	my	$args = { @_ };
	### <where> - reached build_instance ...
	##### <where> - passed arguments: $args
	my ( $class_name, $instance_args ) = build_class( $args );
	my	$instance = $class_name->new( $instance_args );
	##### <where> - instance: $instance
	return $instance;
}

###############  Private Attributes  ####################################################

###############  Private Methods / Modifiers  ###########################################

#################### Phinish with a Phlourish ###########################################

no Moose;
__PACKAGE__->meta->make_immutable;

1;
# The preceding line will help the module return a true value

#################### main pod documentation begin #######################################

__END__

=head1 NAME

MooseX::ShortCut::BuildInstance - A shortcut to build Moose instances

=head1 SYNOPSIS
    
	#!perl
	use Modern::Perl;

	package Mineral;
	use Moose;

	has 'type' =>( is => 'ro' );

	package Identity;
	use Moose::Role;

	has 'name' =>( is => 'ro' );

	use MooseX::ShortCut::BuildInstance qw( build_instance );
	use Test::More;
	use Test::Moose;

	my 	$paco = build_instance(
			package => 'Pet::Rock',
			superclasses =>['Mineral'],
			roles =>['Identity'],
			type => 'Quartz',
			name => 'Paco',
		);

	does_ok( $paco, 'Identity', 'Check that the ' . $paco->meta->name . 
		' has an -Identity-' );
	say 'My ' . $paco->meta->name . ' made from -' . $paco->type . '- (a ' .
		( join ', ', $paco->meta->superclasses ) . ') is called -' . 
		$paco->name . '-';
	done_testing();
    
    ##############################################################################
    #     Output of SYNOPSIS
    # 01:ok 1 - Check that the Pet::Rock has an -Identity-
    # 02:My Pet::Rock made from -Quartz- (a Mineral) is called -Paco-
    # 03:1..1
    ##############################################################################

    
=head1 DESCRIPTION

This module is a shortcut to build L<Moose> instances on the fly.

=head1 Methods

=head2 Methods for Export

=head3 build_instance( %args|\%args )

=over

=item B<Definition:> This method is used to create a Moose instance on the fly.  
I<It assumes that you do not have the class pre-built and will look for the 
needed information to compose a new class as well.>  Basically this passes the 
%args intact to L<build_class|/build_class( %args|\%args )> and then runs 
$returned_class_name->new( %remaining_args );

=item B<Accepts:> a hash or hashref of arguments.  They must include the 
necessary information to build a class.  I<(if you already have a class just 
call $class-E<gt>new(); instead of this method!)> This hashref can also 
contain any attribute settings for the instance as well.


=item B<Returns:> This will return a blessed instance of your new class with 
the passed attributes set.

=back

=head3 build_class( %args|\%args )

=over

=item B<Definition:> This method is used to compose a Moose class on the fly.  
By itself it is redundant to the L<Moose::Meta::Class>->class(%args) method.  
The use of this method is best when paired with 
L<build_instance|/build_instance( %args|\%args )>.  This function takes  
take the passed arguments and strips out three potential key value pairs.  It 
then uses the L<Moose::Meta::Class> module to build a new composed class.  The 
one additional value here is that most key value pairs are optional!  The caveat 
being that some functionality must be passed either through a role or a class.  
This function will handle any other missing key/value pairs not passed.

=item B<Accepts:> a hash or hashref of arguments.  I<These keys are always used 
to build the class.  They are never passed on to %remaining_args.>  The three key 
value pairs use are;

=over

=item B<package> - This is the name (a string) that the new instance of 
a this class is blessed under.  If this key is not provided the package 
will generate a generic name.

=item B<superclasses> - this is intentionally the same key from 
L<Moose::Meta::Class>.  It expects the same values. (Must be Moose classes)

=item B<roles> - this is intentionally the same key from L<Moose::Meta::Class>.  
It expects the same values. (Must be Moose roles)

=back

=item B<Returns:> This will check the caller and see if it wants an array or a 
scalar.  In array context it returns the new class name and a hash ref of the 
unused hash key - value pairs.  These are presumably the arguments for the 
instance.  If the requested return is a scalar it just returns the name of 
the newly created class.

=back

=head1 GLOBAL VARIABLES

=over

=item B<$ENV{Smart_Comments}>

The module uses L<Smart::Comments> if the '-ENV' option is set.  The 'use' is 
encapsulated in a BEGIN block triggered by the environmental variable to comfort 
non-believers.  Setting the variable $ENV{Smart_Comments} will load and turn 
on smart comment reporting.  There are three levels of 'Smartness' available 
in this module '### #### #####'.

=back

=head1 SUPPORT

=over

=item L<MooseX-ShortCut-BuildInstance/issues|https://github.com/jandrew/MooseX-ShortCut-BuildInstance/issues>

=back

=head1 TODO

=over

=item * Add a type package to manage the inputs to the exported methods

=back

=head1 AUTHOR

=over

=item Jed Lund

=item jandrew@cpan.org

=back

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 Dependencies

=over

=item L<version>

=item L<5.010> - use of defined or

=item L<Moose>

=item L<Moose::Meta::Class>

=item L<Moose::Exporter>

=item L<Carp>

=back

=head1 SEE ALSO

=over

=item L<Moose::Meta::Class> ->create

=item L<Moose::Util> ->with_traits

=item L<MooseX::ClassCompositor>

=item L<Smart::Comments> - is used if the -ENV option is set

=back

=cut

#################### main pod documentation end #########################################
