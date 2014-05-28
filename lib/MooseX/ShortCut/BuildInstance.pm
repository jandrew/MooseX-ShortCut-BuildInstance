#########1 Main Package       3#########4#########5#########6#########7#########8#########9
package MooseX::ShortCut::BuildInstance;
use version; our $VERSION = qv("v1.4.2");
use 5.010;
use Moose;
use Moose::Meta::Class;
use Carp qw( cluck );
use Moose::Util qw( apply_all_roles );
use Moose::Exporter;
Moose::Exporter->setup_import_methods(
	as_is => [
		'build_instance',
		'build_class',
		'should_re_use_classes',
		'set_class_immutability',
	],
);
use Types::Standard qw(
		Bool
    );
use Data::Dumper;
use lib	'../../../lib',;
use MooseX::ShortCut::BuildInstance::Types qw(
		BuildClassDict
	);
if( $ENV{ Smart_Comments } ){
	use Smart::Comments -ENV;
	### Smart-Comments turned on for MooseX-ShortCut-BuildInstance  ...
}

#########1 Package Variables  3#########4#########5#########6#########7#########8#########9

our	$instance_count 		= 1;
our	$built_classes			= {};
our	$re_use_classes 		= 0;
our	$make_classes_immutable = 1;
my 	@init_class_args = qw(
		package
		superclasses
		roles
	);
my 	@add_class_args = qw(
		add_roles_in_sequence
		add_attributes
		add_methods
	);

#########1 Public Methods     3#########4#########5#########6#########7#########8#########9

sub build_class{
	### <where> - arrived at build_class ...
	### <where> - with
	
	my	$args = ( scalar( @_ ) == 1 ) ? $_[0] : { @_ };
	my ( $class_args, $i, $can_build, $warning, @warn_list, $pre_exists );
	for my $key ( @init_class_args ){
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
						### <where> - make_mutable: $args->{$key}
						$class_args->{package}->meta->make_mutable;
					}
				}
				$built_classes->{$args->{$key}} = 1;
			}
			delete $args->{$key};
		}elsif( $key eq 'package' ){
			### <where> - missing a package value ...
			$class_args->{$key} = "ANONYMOUS_SHIRAS_MOOSE_CLASS_" . ++$instance_count;
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
	### <where> - Pre exists state: $pre_exists
	### <where> - $warning state: $warning
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
	if( exists $args->{add_attributes} ){
		my	$meta = $class_name->meta;
		for my $attribute ( keys %{$args->{add_attributes}} ){
			### <where> - adding attribute named: $attribute
			$meta->add_attribute( $attribute => $args->{add_attributes}->{$attribute} );
		}
		delete $args->{add_attributes};
	}
	if( exists $args->{add_methods} ){
		my	$meta = $class_name->meta;
		for my $method ( keys %{$args->{add_methods}} ){
			### <where> - adding method named: $method
			$meta->add_method( $method => $args->{add_methods}->{$method} );
		}
		delete $args->{add_methods};
	}
	if( $make_classes_immutable ){
		### <where> - Immutablizing the class ...
		$class_name->meta->make_immutable;
	}
	return $class_name;
}

sub build_instance{
	my	$args = ( ref $_[0] eq 'HASH' ) ? $_[0] : { @_ };
	### <where> - reached build_instance ...
	##### <where> - passed arguments: $args
	my	$class_args;
	for my $key ( @init_class_args, @add_class_args ){
		if( exists $args->{$key} ){
			$class_args->{$key} = $args->{$key};
			delete $args->{$key};
		}
	}
	##### <where> - reduced arguments: $args
	##### <where> - class building arguments: $class_args
	my $class = build_class( $class_args );
	my	$instance = $class->new( $args );
	##### <where> - instance: $instance
	return $instance;
}

sub should_re_use_classes{
	my ( $bool, ) = @_;
	### <where> - setting $re_use_classes to; $bool
	$re_use_classes = ( $bool ) ? 1 : 0 ;
}

sub set_class_immutability{
	my ( $bool, ) = @_;
	### <where> - setting $make_immutable_classes to; $bool
	$make_classes_immutable = ( $bool ) ? 1 : 0 ;
}

#########1 Phinish strong     3#########4#########5#########6#########7#########8#########9

no Moose;
__PACKAGE__->meta->make_immutable;

#########1 Default class      3#########4#########5#########6#########7#########8#########9
package Anonymous::Shiras::Moose::Class;
use	Moose;
no	Moose;

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

This module is a shortcut to custom build L<Moose> class instances on the fly.  
The goal is to compose unique instances of Moose classes on the fly using a single 
set of information describing defininition for attributes, methods, inherited classes 
and roles as well as any instance settings to apply in a 
L<DCI|https://en.wikipedia.org/wiki/Data,_Context,_and_Interaction> fashion.  
This package will check for and fill in any missing pieces as needed so that your 
call can either be complex or very simple.  The goal is to provide configurable 
instance building without stringing together a series of Class-E<gt>method( %args ) 
calls.

Even though this is a Moose based class it provides a functional interface.

=head1 WARNING

Moose (and I think perl 5) can't have two classes with the same name but
different guts coexisting! This means that if you build a class (package) name 
on the fly while building an instance and then recompose a new class (package) with 
the same name but different functionality (different attributes, methods, inherited 
classes or roles) while composing a new instance on the fly then all calls 
to the old instance will use the new class functionality for execution. (Usually 
causing hard to troubleshoot failures)

MooseX::ShortCut::BuildInstance will warn if you overwrite named classes (packages)
built on top of another class (package) also built by MooseX::ShortCut::BuildInstance.  
If you are using the 'build_instance' method to generate multiple instances of 
the same class (by 'package' name) with different attribute settings but built 
with the same functionality then you need to understand the purpose of the 
L<$re_use_classes|/$MooseX::ShortCut::BuildInstance::re_use_classes> global variable.  
An alternative to multiple calls straight to 'build_instance' is to call 
L<build_class|/build_class( %args|\%args )> separatly and then just call -E<gt>new 
against the resulting class name over and over again.  Another alternative is to 
leave the 'package' argument out of 'build_instance' and let this class create a 
unique by-instance anonymous class/package name.

=head1 Functions for Export

=head2 build_instance( %args|\%args )

=over

B<Definition:> This method is used to create a Moose instance on the fly.  
I<It assumes that you do not have the class pre-built and will look for the 
needed information to compose a new class as well.>  Basically this passes the 
%args intact to L<build_class|/build_class( %args|\%args )> first.  All the 
relevant class building pieces will be used and removed from the args and then 
this method will run $returned_class_name->new( %remaining_args ) with what is 
left.

B<Accepts:> a hash or hashref of arguments.  They must include the 
necessary information to build a class.  I<(if you already have a class just 
call $class-E<gt>new( %args ); instead of this method!)> This hashref can also 
contain any attribute settings for the instance as well.  See 
L<build_class|/build_class( %args|\%args )> for more information.

B<Returns:> This will return a blessed instance of your new class with 
the passed attribute settings implemented.

=back

=head2 build_class( %args|\%args )

=over

B<Definition:> This function is used to compose a Moose class on the fly.  The 
the goal is to allow for as much or as little class definition as you want to be 
provided by one function call.  The goal is also to remove as much of the boilerplate 
and logic sequences for class building as possible and let this package handle that.  
The function begins by using the L<Moose::Meta::Class>-E<gt>class(%args) method.  
For this part the function specifically uses the argument callouts 'package', 
'superclasses', and 'roles'.  Any necessary missing pieces will be provided. I<Even 
though L<Moose::Meta::Class>-E<gt>class(%args) allows for the package name to be called 
as the first element of an odd numbered list this implementation does not.  To define 
a 'package' name it must be set as the value of the 'package' key in the %args.>  
This function then takes the following arguements; 'add_roles_in_sequence', 
'add_attributes', and 'add_methods' and implements them in that order.   The 
implementation of these values is done with L<Moose::Util> 'apply_all_roles' 
and the meta capability in L<Moose>.

B<Accepts:> a hash or hashref of arguments.  I<These keys are always used 
to build the class.  They are never passed on to %remaining_args.>  The six 
key-E<gt>value pairs use are;

=over

B<package:> This is the name (a string) that the new instance of 
a this class is blessed under.  If this key is not provided the package 
will generate a generic name.  This will L<overwrite|/WARNING> any class 
built earlier with the same name.

=over

B<accepts:> a string

=back

B<superclasses:> this is intentionally the same key from 
Moose::Meta::Class-E<gt>create.

=over

B<accepts:> a recognizable (by Moose) class name

=back

B<roles:> this is intentionally the same key from Moose::Meta::Class
-E<gt>create.

=over

B<accepts:> a recognizable (by Moose) class name

=back

B<add_roles_in_sequence:> this will compose, in sequence, each role in 
the array ref into the class built on the prior three arguments using 
L<Moose::Util> apply_all_roles.  This will allow an added role to 
'require' elements of a role earlier in the sequence.  The roles 
implemented with the L<role|/roles:> key are installed first and in a 
group. Then these roles are installed one at a time.

=over

B<accepts:> an array ref list of roles recognizable (by Moose) as roles

=back

B<add_attributes:> this will add attributes to the class using the 
L<Moose::Meta::Class>-E<gt>add_attribute method.  Because these definitions 
are passed as key / value pairs in a hash ref they are not added in 
any specific order.

=over

B<accepts:> a hash ref where the keys are attribute names and the values 
are hash refs of the normal definitions used to define a Moose attribute.

=back


B<add_roles_in_sequence:>  this will add methods to the class using the 
L<Moose::Meta::Class>-E<gt>add_method method.  Because these definitions 
are passed as key / value pairs in a hash ref they are not added in 
any specific order.

=over

B<accepts:> a hash ref where the keys are method names and the values 
are anonymous subroutines or subroutine references.

=back

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
L<MooseX::ShortCut::BuildInstance::re_use_classes
|/$MooseX::ShortCut::BuildInstance::re_use_classes>

=back

=head3 set_class_immutability( $bool )

=over

This sets/changes the global variable 
L<MooseX::ShortCut::BuildInstance::make_classes_immutable
|/$MooseX::ShortCut::BuildInstance::make_classes_immutable>

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
in warning.  This can be changed with the exported method L<should_re_use_classes
|/should_re_use_classes( $bool )>.

=head4 $MooseX::ShortCut::BuildInstance::make_classes_immutable

This is a boolean (1|0) variable that manages whether a class is immutabilized at the end of 
creation.  This can be changed with the exported method L<set_class_immutability
|/set_class_immutability( $bool )>.

=head1 SUPPORT

=over

L<MooseX-ShortCut-BuildInstance/issues|https://github.com/jandrew/MooseX-ShortCut-BuildInstance/issues>

=back

=head1 TODO

=over

B<1.> Swap L<Smart::Comments|https://metacpan.org/module/Smart::Comments> 
for L<Log::Shiras|https://github.com/jandrew/Log-Shiras>

=over

My first attempt ran into some deep recursion issues since this is used 
heavily in my development of Log::Shiras already.

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

L<version>

L<5.010|http://perldoc.perl.org/perl5100delta.html> (for use of 
L<defined or|http://perldoc.perl.org/perlop.html#Logical-Defined-Or> //)

L<Moose>

L<Moose::Meta::Class>

L<Carp> - cluck

L<Moose::Exporter>

L<Moose::Util> - apply_all_roles

L<Moose::Exporter>

L<Types::Standard>

L<Data::Dumper>

L<MooseX::ShortCut::BuildInstance::Types>

=back

=head1 SEE ALSO

=over

L<Moose::Meta::Class> ->create

L<Moose::Util> ->with_traits

L<MooseX::ClassCompositor>

L<Smart::Comments> - 
is used if the -ENV option is set

=back

=cut

#########1#########2 main pod documentation end  5#########6#########7#########8#########9