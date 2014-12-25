#########1 Main Package       3#########4#########5#########6#########7#########8#########9
package MooseX::ShortCut::BuildInstance;
# ABSTRACT: A shortcut to build Moose instances

use version 0.77; our $VERSION = qv("v1.34.2");
use 5.010;
use Moose 2.1213;
use Moose::Meta::Class;
use Types::Standard 0.046 qw( Bool );
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
use Data::Dumper;
use lib	'../../../lib',;
use MooseX::ShortCut::BuildInstance::Types 1.028 qw(
		BuildClassDict
	);
use MooseX::ShortCut::BuildInstance::UnhideDebug;
###LogSD warn "You uncovered internal logging statements for MooseX::ShortCut::BuildInstance!";
###LogSD use Log::Shiras::Telephone;

#########1 Package Variables  3#########4#########5#########6#########7#########8#########9

our	$anonymous_class_count	= 0;
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
	
	my	$args = ( scalar( @_ ) == 1 ) ? $_[0] : { @_ };
	###LogSD	my	$phone = Log::Shiras::Telephone->new(
	###LogSD					name_space 	=> 'build_class', );
	###LogSD		$phone->talk( level => 'info', message =>[
	###LogSD			"Arrived at build_class with args:", $args, ] );
	my ( $class_args, $i, $can_build, $warning, @warn_list, $pre_exists );
	for my $key ( @init_class_args ){
		###LogSD	$phone->talk( level => 'debug', message =>[
		###LogSD		"Processing the class argument: $key", ] );
		if( exists $args->{$key} ){
			###LogSD	$phone->talk( level => 'debug', message =>[
			###LogSD		'Processing the values:', $args->{$key}, ] );
			$class_args->{$key} = $args->{$key};
			if( $key eq 'package' ){
				if( $built_classes->{$args->{$key}} ){
					$pre_exists = 1;
					if( !$re_use_classes ){
						push @warn_list, 'You already built the class: ' . $args->{$key};
						$warning = 1;
						###LogSD	$phone->talk( level => 'warn', message =>[
						###LogSD		"unmutablizing the class ...", @warn_list ] );
						$args->{$key}->meta->make_mutable;
					}
				}
				$built_classes->{$args->{$key}} = 1;
			}
			delete $args->{$key};
		}elsif( $key eq 'package' ){
			$class_args->{$key} = "ANONYMOUS_SHIRAS_MOOSE_CLASS_" . ++$anonymous_class_count;
			###LogSD	$phone->talk( level => 'warn', message =>[
			###LogSD		"missing a package value - using: " . $class_args->{$key} ] );
		}elsif( $key eq 'superclasses' ){
			### <where> - missing the superclass ...
			$class_args->{$key} = [ 'Anonymous::Shiras::Moose::Class' ],
			###LogSD	$phone->talk( level => 'warn', message =>[
			###LogSD		"missing the superclass value - using: " . $class_args->{$key} ] );
		}
	}
	if( $warning ){
		push @warn_list, 'The old class definitions will be overwritten with args:', Dumper( $class_args );
		cluck( join( "\n", @warn_list ) );
		###LogSD	$phone->talk( level => 'warn', message =>[
		###LogSD		'The old class definitions will be overwritten with args:',  $class_args ] );
	}
	my $want_array = ( caller(0) )[5];
	###LogSD	$phone->talk( level => 'trace', message =>[
	###LogSD		'class args:', $class_args, 'remaining arguments:', $args,
	###LogSD		"want array: $want_array", "Pre exists state: " . ($pre_exists//''), 
	###LogSD		"\$warning state: " . ($warning//''),	'finalize the class name or load a new one ...' ] );
	my	$class_name = ( $pre_exists and !$warning ) ?
			$class_args->{package} :
			Moose::Meta::Class->create( %{$class_args} )->name;
	###LogSD	$phone->talk( level => 'debug', message =>[
	###LogSD		'class to this point: ' . $class_name->dump( 2 ) ] );
	if( !$class_name->meta->is_mutable and
		(	exists $args->{add_attributes} or
			exists $args->{add_methods} or
			exists $args->{add_roles_in_sequence} ) ){
		###LogSD	$phone->talk( level => 'info', message =>[
		###LogSD		'Unmutablizing the class ...' ] );
		$class_name->meta->make_mutable;
	}
	if( exists $args->{add_attributes} ){
		my	$meta = $class_name->meta;
		for my $attribute ( keys %{$args->{add_attributes}} ){
			###LogSD	$phone->talk( level => 'debug', message =>[
			###LogSD		"adding attribute named: $attribute" ] );
			$meta->add_attribute( $attribute => $args->{add_attributes}->{$attribute} );
		}
		delete $args->{add_attributes};
	}
	if( exists $args->{add_methods} ){
		my	$meta = $class_name->meta;
		for my $method ( keys %{$args->{add_methods}} ){
			###LogSD	$phone->talk( level => 'debug', message =>[
			###LogSD		"adding method named: $method" ] );
			$meta->add_method( $method => $args->{add_methods}->{$method} );
		}
		delete $args->{add_methods};
	}
	if( exists $args->{add_roles_in_sequence} ){
		for my $role ( @{$args->{add_roles_in_sequence}} ){
			###LogSD	$phone->talk( level => 'debug', message =>[ "adding role: $role" ] );
			apply_all_roles( $class_name, $role );
		}
		delete $args->{add_roles_in_sequence};
	}
	if( $make_classes_immutable ){
		###LogSD	$phone->talk( level => 'info', message =>[
		###LogSD		'Immutablizing the class ...' ] );
		$class_name->meta->make_immutable;
	}
	###LogSD	$phone->talk( level => 'info', message =>[
	###LogSD		"returning: $class_name" ] );
	return $class_name;
}

sub build_instance{
	my	$args = ( ref $_[0] eq 'HASH' ) ? $_[0] : { @_ };
	###LogSD	my	$phone = Log::Shiras::Telephone->new(
	###LogSD					name_space 	=> 'build_instance', );
	###LogSD		$phone->talk( level => 'info', message =>[
	###LogSD			"Arrived at build_instance with args:", $args, ] );
	my	$class_args;
	for my $key ( @init_class_args, @add_class_args ){
		if( exists $args->{$key} ){
			$class_args->{$key} = $args->{$key};
			delete $args->{$key};
		}
	}
	###LogSD	$phone->talk( level => 'trace', message =>[
	###LogSD		'Reduced arguments:', $args,
	###LogSD		'Class building arguments:', $class_args, ] );
	my $class = build_class( $class_args );
	###LogSD	$phone->talk( level => 'trace', message =>[
	###LogSD		"Built class name: $class",
	###LogSD		"To get instance now applying args:", $args, ] );
	my $instance;
	eval '$instance = $class->new( %$args )';
	if( $@ ){
		my $message = $@;
		if( ref $message ){
			if( $message->can( 'as_string' ) ){
				$message = $message->as_string;
			}elsif( $message->can( 'message' ) ){
				$message = $message->message;
			}
		}
		$message =~ s/\)\n;/\);/g;
		###LogSD	$phone->talk( level => 'fatal', message =>[
		###LogSD		"Failed to build -$class- for: $message", ] );
		warn $message;
	}else{
		###LogSD	$phone->talk( level => 'trace', message =>[
		###LogSD		"Built instance:", $instance, ] );
		return $instance;
	}
}

sub should_re_use_classes{
	my ( $bool, ) = @_;
	###LogSD	my	$phone = Log::Shiras::Telephone->new(
	###LogSD					name_space 	=> 'should_re_use_classes', );
	###LogSD		$phone->talk( level => 'info', message =>[
	###LogSD			"setting \$re_use_classes to: $bool", ] );
	$re_use_classes = ( $bool ) ? 1 : 0 ;
}

sub set_class_immutability{
	my ( $bool, ) = @_;
	###LogSD	my	$phone = Log::Shiras::Telephone->new(
	###LogSD					name_space 	=> 'set_class_immutability', );
	###LogSD		$phone->talk( level => 'info', message =>[
	###LogSD			"setting \$make_immutable_classes to; $bool", ] );
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

	use MooseX::ShortCut::BuildInstance;
	use Test::More;
	use Test::Moose;

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
function call with information describing required attributes, methods, inherited 
classes, and roles as well as any instance settings to apply in a 
L<DCI|https://en.wikipedia.org/wiki/Data,_Context,_and_Interaction> fashion.  
This package will check for and fill in any missing pieces as needed so that your 
call can either be complex or very simple.  The goal is to provide configurable 
instance building without stringing together a series of Class-E<gt>method( %args ) 
calls.

The package can also be used as a class factory with the L<should_re_use_classes
|/$MooseX::ShortCut::BuildInstance::re_use_classes> method.

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
L<build_class|/build_class( %args|\%args )> separately and then just call -E<gt>new 
against the resulting class name over and over again.  Another alternative is to 
leave the 'package' argument out of 'build_instance' and let this class create a 
unique by-instance anonymous class/package name.

The Types module in this package uses L<Type::Tiny> which can, in the 
background, use L<Type::Tiny::XS>.  While in general this is a good thing you will 
need to make sure that Type::Tiny::XS is version 0.010 or newer since the older 
ones didn't support the 'Optional' method.

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
This function then takes the following arguements; 'add_attributes', 'add_methods', 
and 'add_roles_in_sequence' and implements them in that order.   The 
implementation of these values is done with L<Moose::Util> 'apply_all_roles' 
and the meta capability in L<Moose>.

B<Accepts:> a hash or hashref of arguments.  Six keys are stripped from the hash or 
hash ref of arguments.  I<These keys are always used to build the class.  They are 
never passed on to %remaining_args.>

=over

B<The first three key-E<gt>value pairs are consumed simultaneously>.  They are;

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

=back

B<The second three key-E<gt>value pairs are consumed in the following 
sequence>.  They are;

=over

B<add_attributes:> this will add attributes to the class using the 
L<Moose::Meta::Class>-E<gt>add_attribute method.  Because these definitions 
are passed as key / value pairs in a hash ref they are not added in 
any specific order.

=over

B<accepts:> a hash ref where the keys are attribute names and the values 
are hash refs of the normal definitions used to define a Moose attribute.

=back


B<add_methods:>  this will add methods to the class using the 
L<Moose::Meta::Class>-E<gt>add_method method.  Because these definitions 
are passed as key / value pairs in a hash ref they are not added in 
any specific order.

=over

B<accepts:> a hash ref where the keys are method names and the values 
are anonymous subroutines or subroutine references.

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

=back

=back

B<Returns:> This will check the caller and see if it wants an array or a 
scalar.  In array context it returns the new class name and a hash ref of the 
unused hash key/value pairs.  These are presumably the arguments for the 
instance.  If the requested return is a scalar it just returns the name of 
the newly created class.

=back

=head2 should_re_use_classes( $bool )

=over

This sets/changes the global variable 
L<MooseX::ShortCut::BuildInstance::re_use_classes
|/$MooseX::ShortCut::BuildInstance::re_use_classes>

=back

=head2 set_class_immutability( $bool )

=over

This sets/changes the global variable 
L<MooseX::ShortCut::BuildInstance::make_classes_immutable
|/$MooseX::ShortCut::BuildInstance::make_classes_immutable>

=back

=head1 GLOBAL VARIABLES

=head2 $MooseX::ShortCut::BuildInstance::anonymous_class_count

This is an integer that increments and appends to the anonymous package name 
for each new anonymous package (class) created.

=head2 $MooseX::ShortCut::BuildInstance::built_classes

This is a hashref that tracks the class names ('package's) built buy this class 
to manage duplicate build behaviour.

=head2 $MooseX::ShortCut::BuildInstance::re_use_classes

This is a boolean (1|0) variable that tracks if the class should overwrite or 
re-use a package name (and the defined class) from a prior 'build_class' call.  
If the package name is overwritten it will L<cluck|https://metacpan.org/pod/Carp#SYNOPSIS> 
in warning since any changes will affect active instances of prior class builds 
with the same name.  If you wish to avoid changing old built behaviour at the risk 
of not installing new behaviour then set this variable to true.  I<No warning will 
be provided if new requested class behaviour is discarded.> The class reuse behaviour 
can be changed with the exported method L<should_re_use_classes
|/should_re_use_classes( $bool )>.

=over

B<Default:> False = warn then overwrite

=back

=head2 $MooseX::ShortCut::BuildInstance::make_classes_immutable

This is a boolean (1|0) variable that manages whether a class is immutabilized at the end of 
creation.  This can be changed with the exported method L<set_class_immutability
|/set_class_immutability( $bool )>.

=head1 Build/Install from Source

=over
	
B<1.> Download a compressed file with the code
	
B<2.> Extract the code from the compressed file.

=over

If you are using tar this should work:

	tar -zxvf Spreadsheet-XLSX-Reader-LibXML-v0.xx.tar.gz
	
=back

B<3.> Change (cd) into the extracted directory

B<4.> Run the following

=over

(For Windows find what version of make was used to compile your perl)

	perl  -V:make
	
(for Windows below substitute the correct make function (s/make/dmake/g)?)
	
=back

	>perl Makefile.PL

	>make

	>make test

	>make install # As sudo/root

	>make clean
	
=back

=head1 SUPPORT

=over

L<MooseX-ShortCut-BuildInstance/issues|https://github.com/jandrew/MooseX-ShortCut-BuildInstance/issues>

=back

=head1 TODO

=over

B<1.> Pending ideas

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

This software is copyrighted (c) 2012, 2013, 2014 by Jed Lund

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

L<Type::Tiny> - 0.046

L<Data::Dumper>

L<MooseX::ShortCut::BuildInstance::Types>

=back

=head1 SEE ALSO

=over

L<Moose::Meta::Class> ->create

L<Moose::Util> ->with_traits

L<MooseX::ClassCompositor>

L<Log::Shiras|https://github.com/jandrew/Log-Shiras>

=over

This package does not use Log::Shiras functionality by default.  The functionality is 
only turned on if the variable $ENV{log_shiras_filter_on} is set to true.  Otherwise 
all the Log::Shiras code is hidden as comments.  See 
L<MooseX::ShortCut::BuildInstance::UnhideDebug> for more information.

=back

=back

=cut

#########1#########2 main pod documentation end  5#########6#########7#########8#########9
