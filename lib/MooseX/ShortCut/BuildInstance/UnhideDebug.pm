package MooseX::ShortCut::BuildInstance::UnhideDebug;
use version; our $VERSION = version->declare('v1.34.8');

use 5.010;
use strict;
use warnings;

#########1 Package Variables  3#########4#########5#########6#########7#########8#########9

my $debug_flag = 0;

#########1 import   2#########3#########4#########5#########6#########7#########8#########9

sub import {
    my( $class, ) = @_;
	
    if( defined $ENV{log_shiras_filter_on} ) {
		print "Running MooseX::ShortCut::BuildInstance::UnhideDebug filter!\n" if $debug_flag;
        my $FILTER_MODULE = "Filter::Util::Call";
        if(! "require $FILTER_MODULE" ) {
            die "$FILTER_MODULE required with :debug" .
                "(install from CPAN)";
        }
		
        eval "require $FILTER_MODULE" or die "Cannot pull in $FILTER_MODULE";
        Filter::Util::Call::filter_add(
            sub{
                my $status;
				if( ($status = Filter::Util::Call::filter_read()) > 0 ){
					print "-->$_" if $debug_flag;
					s/^(\s*)###LogSD\s/$1         /mg;
					print "<--$_\n" if $debug_flag;
				}
                return $status;
			}
		);
    }
}

#########1 Phinish            3#########4#########5#########6#########7#########8#########9
	
1;

#########1 Documentation      3#########4#########5#########6#########7#########8#########9
__END__

=head1 NAME

MooseX::ShortCut::BuildInstance::UnhideDebug - Unhides debug lines for Log::Shiras

=head1 DESCRIPTION

This package definitly falls in the dark magic catagory of perl and it is a source filter 
using L<Filter::Util::Call>.  Activiation (exposure) of debug lines will only slow your 
code down.  Don't do it if you arn't willing to pay the price.  The value of exposing 
those lines is all the interesting information you receive from the debugging code.  To 
use this file you must install as a minimum L<Log::Shiras::Switchboard
|https://github.com/jandrew/Log-Shiras/blob/master/lib/Log/Shiras/SwitchBoard.pm> and 
L<Log::Shiras::Telephone
|https://github.com/jandrew/Log-Shiras/blob/master/lib/Log/Shiras/Telephone.pm>  from 
github in one of your module L<lib>raries.  I<Yes that code is definitly in alpha state 
(at best).>

B<The good news for anyone that is not interested in using this class is that none of the 
L<DEPENDENCIES|/DEPENDENCIES> are activated and none of the package debug lines are exposed 
to slow the code down unless the ':debug' flag is sent to L<Log::Shiras::Switchboard
|https://github.com/jandrew/Log-Shiras/blob/master/lib/Log/Shiras/SwitchBoard.pm>.>  
I<Read that as it won't happen if you don't install and use Log::Shiras and the package will 
run just fine without installing it.>
	
This class is a source filter with the single purpose of uhiding '###LogSD' (B<S>hiras 
B<D>ebug) debug lines written in this package and activated by L<Log::Shiras
|https://github.com/jandrew/Log-Shiras>.  L<MooseX::ShortCut::BuildInstance> is used by 
Log-Shiras internally and gets 'used' there so that the specific timing of any source 
filter implementation for this package must fall after the L<Switchboard
|https://github.com/jandrew/Log-Shiras/blob/master/lib/Log/Shiras/SwitchBoard.pm> 
':debug'ing is set on or off and before any other classes can be called like 
L<Log::Shiras::UnhideDebug
|https://github.com/jandrew/Log-Shiras/blob/master/lib/Log/Shiras/UnhideDebug.pm>.  The 
implementation of the delay in calling MooseX::ShortCut::BuildInstance within Log::Shiras 
till after a decision on debug implementation is accomplished with an L<eval EXPR
|http://perldoc.perl.org/functions/eval.html> line.  
The source filter is then needed immediatly so it cannot be implemented with a generic 
source filter like Log::Shiras::UnhideDebug.  A class specific source filter is therefore 
needed to resolve that.  The source filter here triggers off the environmental variable 
$ENV{log_shiras_filter_on} which is set when the ':debug' flag is passed to 'use 
Log::Shiras::Switchboard @args' in the @args.  Since this package provides only a functional 
interface all the debug namespaces of the exposed functions are the names of the functions 
themselves.  The namespaces in this package do not inherit pre-fixes from the consuming class.  
(Generally I write namespaces for object methods that do inherit pre-fixes from the parent 
class.)

For this class to work any call for 'use MooseX::ShortCut::BuildInstance' must occur after 
the call to 'use Log::Shiras::Switchboard qw( :debug );'.  Otherwize the class will be 
loaded without the debug lines exposed.

=head1 SUPPORT

=over

L<MooseX-ShortCut-BuildInstance/issues|https://github.com/jandrew/MooseX-ShortCut-BuildInstance/issues>

or

L<github Log-Shiras/issues|https://github.com/jandrew/Log-Shiras/issues>

=back

=head1 TODO

=over

B<1.> Remove raw links to Log-Shiras files in the github repo when Log-Shiras is published to CPAN

B<2.> Write a test suit for this class - pending release of Log-Shiras to CPAN 
(also skip the test if Log::Shiras is not installed)

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

This software is copyrighted (c) 2012 and 2015 by Jed Lund

=head1 DEPENDENCIES

=over

L<version>

L<Filter::Util::Call>

L<Log::Shiras::Switchboard>

L<Log::Shiras::Telephone>

=back

=cut

#########1#########2 main pod documentation end  5#########6#########7#########8#########9