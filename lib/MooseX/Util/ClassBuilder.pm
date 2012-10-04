package MooseX::Util::ClassBuilder;
use 5.010;
use Moose;
use Moose::Meta::Class;
use version; our $VERSION = qv('0.001_001');
use Moose::Exporter;
Moose::Exporter->setup_import_methods(
	as_is => [ 'build_class', 'build_instance' ],
);

BEGIN{
	if( $ENV{ Smart_Comments } ){
		use Smart::Comments -ENV;
		### Smart-Comments turned on for MooseX-Util-ClassBuilder ...
	}
}

###############  Package Variables  #####################################################

our	$instance_count //= 1;

###############  Dispatch Tables  #######################################################

###############  Public Attributes  #####################################################

###############  Public Methods  ########################################################

sub build_class{
	### <where> - reached build_class ...
	##### <where> - passed arguments: @_
	my	$args = ( scalar( @_ ) == 1 ) ? $_[0] : { @_ };
	my ( $name, $class_args );
	if( exists $args->{class_name} ){
		$name = $args->{class_name};
		delete $args->{class_name};
	}else{
		$name = "ANONYMOUS_SHIRAS_MOOSE_CLASS_" . $instance_count++;
	}
	if( exists $args->{superclasses} ){
		$class_args->{superclasses} = $args->{superclasses};
		delete $args->{superclasses};
	}
	if( exists $args->{roles} ){
		$class_args->{roles} = $args->{roles};
		delete $args->{roles};
	}
	my $want_array = ( caller(0) )[5];
	### <where> - name: $name
	### <where> - class args: $class_args
	### <where> - remaining arguments: $args
	### <where> - want array: $want_array
	my 	$class_name =	Moose::Meta::Class->create(
							$name, %{$class_args},
						)->name;
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

MooseX::Util::ClassBuilder - Yet another way to build Moose Classes

=head1 SYNOPSIS
    
	#!perl
	use Modern::Perl;

	package Mineral;
	use Moose;

	has 'type' =>( is => 'ro' );

	package Identity;
	use Moose::Role;

	has 'name' =>( is => 'ro' );

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
    
    ############################################################################
    #     Output of SYNOPSIS
    # 01:ok 1 - Check that the Pet::Rock has an -Identity-
    # 02:My Pet::Rock made from -Quartz- (a Mineral) is called -Paco-
    # 03:1..1
    ##############################################################################

    
=head1 DESCRIPTION

This module is used to compose Moose classes and instances on the fly.

=head1 Methods

=head2 Exported Methods

=head3 build_class( %args|\%args )

=over

=item B<Definition:> This method is used to compose a Moose Class.  It will 
take the passed arguments and strip out three potential key value pairs.  It 
then uses the L<Moose::Meta::Class> module to build a new composed class.

=item B<Accepts:> a hash or hashref of arguments.  The three key value pairs 
use are;

=over

=item B<class_name> - This is the name (a string) that the new instance of 
a this class is blessed under.  If this key is not provided the package 
will generate a generic name.

=item B<superclasses> - this is intentionally the same key from 
L<Moose::Meta::Class>.  It expects the same values.

=item B<roles> - this is intentionally the same key from L<Moose::Meta::Class>.  
It expects the same values.

=back

=item B<Returns:> This will check the caller and see if it wants an array or a 
scalar.  In array context it returns the new class name and a hash ref of the 
unused hash key - value pairs.  These are presumably the arguments for the 
instance.  If the requested return is a scalar it just returns the name of 
the newly created class.

=back

=head3 build_instance( %args|\%args )

=over

=item B<Definition:> This method is used to create a Moose Class instance.  I<It 
assumes that you do not have the class pre-built and will look for the needed 
information to compose a new class as well.>  Basically this passes the %args 
intact to L<build_class|/build_class( %args|\%args )> and then runs 
$returned_class_name->new( %remaining_args );

=item B<Accepts:> a hash or hashref of arguments.  They must include the 
necessary information to build a class.  I<(if you already have a class just 
call $class-E<gt>new(); instead of this method!)> This hashref can also 
contain any attribute settings for the instance as well.


=item B<Returns:> This will return a blessed instance of your new class with 
the passed attributes set.

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

=item L<MooseX-Util-ClassBuilder/issues|https://github.com/jandrew/MooseX-Util-ClassBuilder/issues>

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

=back

=head1 SEE ALSO

=over

=item L<Moose::Util> - with_traits

=item L<MooseX::ClassCompositor>

=item L<Smart::Comments> - is used if the -ENV option is set

=back

=cut

#################### main pod documentation end #########################################
