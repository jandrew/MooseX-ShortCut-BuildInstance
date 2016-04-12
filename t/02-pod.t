#!perl
### Test that the pod files run
use Test::More 1.0;
eval "use Test::Pod 1.48";
if( $@ ){
	plan skip_all => "Test::Pod 1.48 required for testing POD";
}else{
	plan tests => 4;
}
my	$up		= '../';
for my $next ( <*> ){
	if( ($next eq 't') and -d $next ){
		### <where> - found the t directory - must be using prove ...
		$up	= '';
		last;
	}
}
pod_file_ok( $up . 	'README.pod',
						"The README file has good POD" );
pod_file_ok( $up . 	'lib/MooseX/Shortcut/BuildInstance/Types.pm',
						"The MooseX::Shortcut::BuildInstance::Types file has good POD" );
pod_file_ok( $up . 	'lib/MooseX/Shortcut/BuildInstance/UnhideDebug.pm',
						"The MooseX::Shortcut::BuildInstance::UnhideDebug file has good POD" );
pod_file_ok( $up . 	'lib/MooseX/Shortcut/BuildInstance.pm',
						"The MooseX::Shortcut::BuildInstance file has good POD" );
done_testing();