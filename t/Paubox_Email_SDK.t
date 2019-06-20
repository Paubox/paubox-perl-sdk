use strict;
use warnings;
use lib "t/lib";
use Paubox_Email_SDK::Test;
use Test::More tests => 25;
BEGIN { use_ok('Paubox_Email_SDK') };

Test::Class->runtests;
