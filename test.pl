# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 6 };
use Carp;
ok(1);
use Compress::Zlib;
ok(2);
use Digest::MD5;
ok(3);
use Exporter;
ok(4);
use Data::Dumper;
ok(5);
use PDF::Reuse;
ok(6); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

