#########1 Test File for MooseX::ShortCut::BuildInstance::Types       7#########8#########9
#!perl
BEGIN{
	#~ $ENV{ Smart_Comments } = '### ####'; #####
}
if( $ENV{ Smart_Comments } ){
	use Smart::Comments -ENV;
	### Smart-Comments turned on for MooseX-ShortCut-BuildInstance-Types test...
}
$| = 1;

use	Test::Most;
use	Test::Moose;
use Data::Dumper;
use Capture::Tiny qw( capture_stderr );
use Type::Tiny::XS 0.010;
use Types::Standard -types;
use	lib 
		'../../../../lib',;
use MooseX::ShortCut::BuildInstance::Types v1.16 qw(
		NameSpace
		SuperClassesList
		RolesList
		Attributes
		Methods
		BuildClassDict
	);
my  ( 
			$position, $counter, $capture,
	);
my 			$row = 0;
my			$question_ref =[
				'Test', 'MooseX::ShortCut::BuildInstance::Types',
				'Bad-Name',
				[ 'Test::Most' ], [ 'MooseX::ShortCut::BuildInstance::Types', 'Data::Dumper' ],
				[],undef,['Test'],
				[ 'Test::Role' ],
				[],undef,['Test::Class'],
				{ check => { is => 'ro', isa => Str } },
				[],undef,{ check => [ is => 'ro', isa => Str ] },
				{ check => sub{ print $_ } },
				[],undef,{ check => [] },
				{
					package			=> 'On::The::Fly',
					superclasses	=>[ 'Test::Class' ],
					roles			=>[ 'Test::Role' ]
				},
				[],undef,{ check => [] },
			];
my			$answer_ref = [
				undef, undef,
				qr/\-Bad\-Name\-\ does not match.*\[A\-Za\-z\:\]/,
				undef, undef,
				qr/scalar \@\$_ > 0/,
				qr/Undef did not pass type constraint "Defined"/,
				qr/Value "Test" did not pass type constraint "ClassName" \(in \$_->\[0\]\)/,
				undef,
				qr/scalar \@\$_ > 0/,
				qr/Undef did not pass type constraint "Defined"/,
				qr/Value "Test::Class" did not pass type constraint "RoleName" \(in \$_->\[0\]\)/,
				undef,
				qr/Reference \[\] did not pass type constraint "HashRef"/,
				qr/Undef did not pass type constraint "Defined"/,
				qr/Reference \[.+\] did not pass type constraint "HashRef"/,
				undef,
				qr/Reference \[\] did not pass type constraint "HashRef"/,
				qr/Undef did not pass type constraint "Defined"/,
				qr/Reference \[\] did not pass type constraint "CodeRef"/,
				undef,
				qr/Reference \[\] did not pass type constraint "HashRef"/,
				qr/Undef did not pass type constraint "Defined"/,
				qr/does not allow key "check" to appear in hash/,
			];
### Types Tests ...
			map{
ok			NameSpace->( $question_ref->[$_] ),
							"Check that a good NameSpace passes: $question_ref->[$_]";
			} ( 0..1 );
			map{
dies_ok{	NameSpace->( $question_ref->[$_] ) }
							"Check that a bad NameSpace fails: $question_ref->[$_]";
like		$@, $answer_ref->[$_],
							"... and check for the correct error message";
			} ( 2..2 );
			map{
ok			SuperClassesList->( $question_ref->[$_] ),
							"Check that a good SuperClassesList passes: " . Dumper( $question_ref->[$_] );
			} ( 3..4 );
			map{
dies_ok{	SuperClassesList->( $question_ref->[$_] ) }
							"Check that a bad SuperClassesList fails: ". Dumper( $question_ref->[$_] );
like		$@, $answer_ref->[$_],
							"... and check for the correct error message";
			} ( 5..7 );
			map{
ok			RolesList->( $question_ref->[$_] ),
							"Check that a good RolesList passes: " . Dumper( $question_ref->[$_] );
			} ( 8..8 );
			map{
dies_ok{	RolesList->( $question_ref->[$_] ) }
							"Check that a bad RolesList fails: ". Dumper( $question_ref->[$_] );
like		$@, $answer_ref->[$_],
							"... and check for the correct error message";
			} ( 9..11 );
			map{
ok			Attributes->( $question_ref->[$_] ),
							"Check that a good Attributes passes: " . Dumper( $question_ref->[$_] );
			} ( 12..12 );
			map{
dies_ok{	Attributes->( $question_ref->[$_] ) }
							"Check that a bad Attributes fails: ". Dumper( $question_ref->[$_] );
like		$@, $answer_ref->[$_],
							"... and check for the correct error message";
			} ( 13..15 );
			map{
ok			Methods->( $question_ref->[$_] ),
							"Check that a good Methods passes: " . Dumper( $question_ref->[$_] );
			} ( 16..16 );
			map{
dies_ok{	Methods->( $question_ref->[$_] ) }
							"Check that a bad Methods fails: ". Dumper( $question_ref->[$_] );
like		$@, $answer_ref->[$_],
							"... and check for the correct error message: " . $answer_ref->[$_];
			##### <where> - against returned error: $@
			} ( 17..19 );
			map{
			### <where> - made it this far!
ok			BuildClassDict->( $question_ref->[$_] ),
							"Check that a good BuildClassDict passes: " . Dumper( $question_ref->[$_] );
			} ( 20..20 );
			map{
dies_ok{	BuildClassDict->( $question_ref->[$_] ) }
							"Check that a bad BuildClassDict fails: ". Dumper( $question_ref->[$_] );
like		$@, $answer_ref->[$_],
							"... and check for the correct error message";
			} ( 21..23 );
explain 								"...Test Done";
done_testing();

package Test::Role;
use Moose::Role;

package Test::Class;
use Moose;

1;