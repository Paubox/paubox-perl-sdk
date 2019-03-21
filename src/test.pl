#!/usr/bin/perl
use strict;
use warnings;
use lib "lib";
use Services::EmailService;
use Data::Message;

use JSON;
use Data::Dumper;

my $attachments = '[{
        "fileName": "hello_world.txt",
        "contentType": "text/plain",
        "content": "SGVsbG8gV29ybGQh\n"
      },
      {
        "fileName": "hello_world2.txt",
        "contentType": "text/plain",
        "content": "SGVsbG8gV29ybGQh\n"
      }
      ]';
my @decoded_json_attachments = @{decode_json($attachments)};

my $msgObj = new Data::Message(
    'renee@test.com',
    'renee@test.com',
    ['vighneshtrivedi2004@gmail.com'],
    ['vighneshtrivedi2004@gmail.com'],
    'Testing from Perl API',
    0, #false
    'This is a Test email',
    '',
    [@decoded_json_attachments],
    );

#print Dumper(\$msgObj);

my $msgResponse = Services::EmailService::sendMessage($msgObj);
print $msgResponse;
my $sourceTrackingId ='4a6d68f7-a528-4691-b4d1-82a822ba59bf';
my $response = Services::EmailService::getEmailDisposition($sourceTrackingId);
