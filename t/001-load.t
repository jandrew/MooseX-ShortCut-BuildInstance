#!perl
### Test that the module(s) load!(s)
use Test::Most;
use lib '../lib', 'lib';
use MooseX::ShortCut::BuildInstance 0.003;
pass		"Test loading the modules in the package";
explain 	"...Test Done";
done_testing();