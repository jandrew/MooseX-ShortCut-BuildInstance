package Identity;
use Moose::Role;
use MooseX::StrictConstructor;

has 'name' =>( 
		is => 'ro',
		#~ reader => 'get_name',
	);
	
no Moose::Role;
1;