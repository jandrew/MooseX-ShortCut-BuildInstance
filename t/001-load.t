#!perl
### Test that the module(s) load!(s)
use Test::Most;
use 5.010;
use version 0.94;
use lib '../lib', 'lib';
use MooseX::ShortCut::BuildInstance 0.008;
pass		"Test loading the modules in the package";
explain 	"...Test Done";
done_testing();