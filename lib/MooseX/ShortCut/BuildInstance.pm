##### main package
package MooseX::ShortCut::BuildInstance;
use version 0.94; our $VERSION = qv('v0.014.002');
use 5.010;
use Moose;
use Moose::Meta::Class;
use Carp qw( cluck );
use Moose::Util qw( apply_all_roles );
use Moose::Exporter;
Moose::Exporter->setup_import_methods(
	as_is => [ 'build_instance', 'build_class', 'should_re_use_classes' ],
);
use MooseX::Types::Moose qw(
		Bool
    );
use Data::Dumper;
if( $ENV{ Smart_Comments } ){
	use Smart::Comments -ENV;
	### Smart-Comments turned on for MooseX-Util-ClassBuilder 0.012 ...
}

#########1 Package Variables  3#########4#########5#########6#########7#########8#########9

our	$instance_count //= 1;
our	$built_classes	= {};
our	$re_use_classes = 0;
my 	@class_args = qw(
		package
		superclasses
		roles
	);

#########1 Public Methods     3#########4#########5#########6#########7#########8#########9

sub build_class{
	### <where> - reached build_class ...
	##### <where> - passed arguments: @_
	my	$args = ( scalar( @_ ) == 1 ) ? $_[0] : { @_ };
	my ( $class_args, $i, $can_build, $warning, @warn_list, $pre_exists );
	for my $key ( @class_args ){
		### <where> - processing the class argument: $key
		if( exists $args->{$key} ){
			### <where> - processing the value: $args->{$key}
			$class_args->{$key} = $args->{$key};
			if( $key eq 'package' ){
				if( $built_classes->{$args->{$key}} ){
					$pre_exists = 1;
					if( !$re_use_classes ){
						push @warn_list, 'You already built the class: ' . $args->{$key};
						$warning = 1;
					}
				}
				$built_classes->{$args->{$key}} = 1;
			}
			delete $args->{$key};
		}elsif( $key eq 'package' ){
			### <where> - missing a package value ...
			$class_args->{$key} = "ANONYMOUS_SHIRAS_MOOSE_CLASS_" . $instance_count++;
		}elsif( $key eq 'superclasses' ){
			### <where> - missing the superclass ...
			$class_args->{$key} = [ 'Anonymous::Shiras::Moose::Class' ],
		}
	}
	if( $warning ){
		push @warn_list, 'The old class definitions will be overwritten with args:', Dumper( $class_args );
		cluck( join( "\n", @warn_list ) );
	}
	my $want_array = ( caller(0) )[5];
	### <where> - class args: $class_args
	### <where> - remaining arguments: $args
	### <where> - want array: $want_array
	my	$class_name = ( $pre_exists and !$warning ) ?
			$class_args->{package} :
			Moose::Meta::Class->create( %{$class_args} )->name;
	### <where> - class to this point: $class_name->dump( 2 )
	if( exists $args->{add_roles_in_sequence} ){
		for my $role ( @{$args->{add_roles_in_sequence}} ){
			### <where> - adding role: $role
			apply_all_roles( $class_name, $role );
		}
		delete $args->{add_roles_in_sequence};
	}
	if( $want_array ){
		return ( $class_name, $args );
	}else{
		return $class_name;
	}
}

sub build_instance{
	my	$args = ( ref $_[0] eq 'HASH' ) ? $_[0] : { @_ };
	### <where> - reached build_instance ...
	##### <where> - passed arguments: $args
	my ( $class, $instance_args ) = build_class( $args );
	my	$instance = $class->new( $instance_args );
	##### <where> - instance: $instance
	return $instance;
}

sub should_re_use_classes{
	my ( $bool, ) = @_;
	### <where> - setting re_use_classes to; $bool
	$re_use_classes = ( $bool ) ? 1 : 0 ;
}

#########1 Phinish strong     3#########4#########5#########6#########7#########8#########9

no Moose;
__PACKAGE__->meta->make_immutable;

##### default package
package Anonymous::Shiras::Moose::Class;
use Moose;
no Moose;
__PACKAGE__->meta->make_immutable;

1;
# The preceding line will help the module return a true value

#########1 main pod docs      3#########4#########5#########6#########7#########8#########9

__END__

=head1 NAME

MooseX::ShortCut::BuildInstance - A shortcut to build Moose instances

=head1 SYNOPSIS
    
	#!perl
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
		$paco->name . "-\n";
	done_testing();
    
    ##############################################################################
    #     Output of SYNOPSIS
    # 01:ok 1 - Check that the Pet::Rock has an -Identity-
    # 02:My Pet::Rock made from -Quartz- (a Mineral) is called -Paco-
    # 03:1..1
    ##############################################################################

    
=head1 DESCRIPTION

This module is a shortcut to custom build L<Moose|https://metacpan.org/pod/Moose> 
class instances on the fly.  The goal is to compose unique instances of Moose 
classes on the fly using roles in a 
L<DCI|https://en.wikipedia.org/wiki/Data,_Context,_and_Interaction> fashion.  
In other words this module accepts all the Moose class building goodness 
along with any roles requested, and any arguments required for a custom 
class instance and checks / fills in missing pieces as needed without stringing 
together a series of Class-E<gt>method( %args ) calls.

Even though this is a Moose based class it provides a functional interface.

=head1 WARNING

Moose (and I think perl 5) can't have two classes with the same name but
different guts coexisting! This means that if you build an instance against a 
given package name on the fly and then recompose a new instance with the same 
package name but containing different functionality all calls to the old instance 
will use the new package functionality for execution. (Usually causing hard to 
troubleshoot failures)

If you are using the 'build_instance' method to generate multiple instances of 
the same class (by 'package' name) with different attribute settings then you 
should understand the functionality that is provided by 
L<should_re_use_classes|/should_re_use_classes( $bool )>.  An alternative is to 
leave the package name out and let this class create a unique by-instance 
anonymous name.

=head1 Methods

=head2 Methods for Export

=head3 build_instance( %args|\%args )

=over

B<Definition:> This method is used to create a Moose instance on the fly.  
I<It assumes that you do not have the class pre-built and will look for the 
needed information to compose a new class as well.>  Basically this passes the 
%args intact to L<build_class|/build_class( %args|\%args )> and then runs 
$returned_class_name->new( %remaining_args ).

B<Accepts:> a hash or hashref of arguments.  They must include the 
necessary information to build a class.  I<(if you already have a class just 
call $class-E<gt>new(); instead of this method!)> This hashref can also 
contain any attribute settings for the instance as well.

B<Returns:> This will return a blessed instance of your new class with 
the passed attributes set.

=back

=head3 build_class( %args|\%args )

=over

B<Definition:> This method is used to compose a Moose class on the fly.  
By itself it is (mostly) redundant to the 
L<Moose::Meta::Class|https://metacpan.org/pod/Moose::Meta::Class>->class(%args) 
method.  This function takes the passed arguments and strips out four potential 
key value pairs.  It then uses the 
L<Moose::Meta::Class|https://metacpan.org/pod/Moose::Meta::Class> module 
and the L<Moose::Util|https://metacpan.org/pod/Moose::Util> module to build a 
new composed class.  There are two incremental values provided by this method 
over Moose::Meta::Class->create.  First, this method makes most of the class 
creation keys optional!  The caveat being that some instance functionality 
must be passed either through a role or a class.  Second,  This method can 
compose roles into the class sequetially allowing for a role to 'require' 
a method from an earlier installed role.

B<Accepts:> a hash or hashref of arguments.  I<These keys are always used 
to build the class.  They are never passed on to %remaining_args.>  The four 
key-E<gt>value pairs use are;

=over

B<package:> This is the name (a string) that the new instance of 
a this class is blessed under.  If this key is not provided the package 
will generate a generic name.  This will L<overwrite|/WARNING> any class 
in 'lib' with the same name.

B<superclasses:> this is intentionally the same key from 
Moose::Meta::Class.  It expects the same values. (Must be Moose classes)

B<roles:> this is intentionally the same key from Moose::Meta::Class.  
It expects the same values. (Must be Moose roles)

B<add_roles_in_sequence:> this will compose, in sequence, each role in 
the array ref into the class built on the prior three arguments using 
L<Moose::Util|https://metacpan.org/module/Moose::Util> apply_all_roles.  
This will allow an added role to 'require' elements of a role earlier in 
the sequence.  The roles listed under 'role' are installed first and in a 
group. Then these roles are installed one at a time.

=back

B<Returns:> This will check the caller and see if it wants an array or a 
scalar.  In array context it returns the new class name and a hash ref of the 
unused hash key/value pairs.  These are presumably the arguments for the 
instance.  If the requested return is a scalar it just returns the name of 
the newly created class.

=back

=head3 should_re_use_classes( $bool )

=over

This sets/changes the global variable 
L<MooseX::ShortCut::BuildInstance::re_use_classes|/MooseX::ShortCut::BuildInstance::re_use_classes>

=back

=head1 GLOBAL VARIABLES

=head4 $ENV{Smart_Comments}

The module uses L<Smart::Comments|https://metacpan.org/module/Smart::Comments> 
if the '-ENV' option is set.  The 'use' is encapsulated in an 'if' block 
triggered by the environmental variable to comfort non-believers.  Setting the 
variable $ENV{Smart_Comments} will load and turn on smart comment reporting.  
There are three levels of 'Smartness' available in this module '### #### #####'.

=head4 $MooseX::ShortCut::BuildInstance::instance_count

This is an integer that increments and appends to the anonymous package name 
for each new anonymous package created.

=head4 $MooseX::ShortCut::BuildInstance::built_classes

This is a hashref that tracks the class names ('package's) built buy this class 
to manage duplicate build behaviour.

=head4 $MooseX::ShortCut::BuildInstance::re_use_classes

This is a boolean (1|0) variable that tracks if the class should overwrite or 
re-use a package name (and the defined class) from a prior 'build_class' call.  
If the package name is overwritten it will L<cluck|https://metacpan.org/pod/Carp#SYNOPSIS> 
in warning.

=head1 SUPPORT

=over

L<MooseX-ShortCut-BuildInstance/issues|https://github.com/jandrew/MooseX-ShortCut-BuildInstance/issues>

=back

=head1 TODO

=over

B<1.> Add a type package to manage the inputs to the exported methods

B<2.> Swap L<Smart::Comments|https://metacpan.org/module/Smart::Comments> 
for L<Log::Shiras|https://github.com/jandrew/Log-Shiras>

=over

(Get Log::Shiras CPAN-ready first!)

=back

=back

=head1 AUTHOR

=over

Jed Lund

jandrew@cpan.org

=back

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

This software is copyrighted (c) 2013 by Jed Lund

=head1 Dependencies

=over

L<version|https://metacpan.org/module/version>

L<5.010|http://perldoc.perl.org/perl5100delta.html> (for use of 
L<defined or|http://perldoc.perl.org/perlop.html#Logical-Defined-Or> //)

L<Moose|https://metacpan.org/module/Moose>

L<Moose::Meta::Class|https://metacpan.org/module/Moose::Meta::Class>

L<Moose::Exporter|https://metacpan.org/module/Moose::Exporter>

L<Moose::Util|https://metacpan.org/module/Moose::Util>

L<MooseX::Types|https://metacpan.org/module/MooseX::Types>

L<Carp|https://metacpan.org/module/Carp> - cluck

L<Data::Dumper|https://metacpan.org/module/Data::Dumper>

=back

=head1 SEE ALSO

=over

L<Moose::Meta::Class|https://metacpan.org/module/Moose::Meta::Class> ->create

L<Moose::Util|https://metacpan.org/module/Moose::Util> ->with_traits

L<MooseX::ClassCompositor|https://metacpan.org/module/MooseX::ClassCompositor>

L<Smart::Comments|https://metacpan.org/module/Smart::Comments> - 
is used if the -ENV option is set

=back

=cut

#################### main pod documentation end #########################################
