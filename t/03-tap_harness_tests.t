#!perl
my	$dir 	= './';
my	$tests	= 'MooseX/ShortCut/';
my	$up		= '../';
for my $next ( <*> ){
	if( ($next eq 't') and -d $next ){
		$dir	= './t/';
		$up		= '';
		last;
	}
}

use	TAP::Formatter::Console;
my $formatter = TAP::Formatter::Console->new({
					jobs => 1,
					#~ verbosity => 1,
				});
my	$args ={
		lib =>[
			$up . 'lib',
			$up,
		],
		formatter => $formatter,
	};
my	@tests =(
		[ $dir . $tests . 'BuildInstance/01-types.t', 'types_test' ],
		[ $dir . $tests . '01-build_instance.t', 'main_test' ],
	);
use	TAP::Harness;
use	TAP::Parser::Aggregator;
my	$harness	= TAP::Harness->new( $args );
my	$aggregator	= TAP::Parser::Aggregator->new;
	$aggregator->start();
	$harness->aggregate_tests( $aggregator, @tests );
	$aggregator->stop();
use Test::More;
explain $formatter->summary($aggregator);
pass( "Test Harness Testing complete" );
done_testing();