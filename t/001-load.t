#!perl
### Test that the module(s) load!(s)
use Test::Most;
use lib '../lib', 'lib';
use MooseX::Util::ClassBuilder 0.001;
pass		"Test loading the modules in the package";
explain 	"...Test Done";
done_testing();