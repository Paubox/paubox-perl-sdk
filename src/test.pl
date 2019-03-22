#!/usr/bin/perl -l
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

my $sourceTrackingId ="4a6d68f7-a528-4691-b4d1-82a822ba59bf";
my $service = Services::EmailService->new();
my $response = $service->getEmailDisposition($sourceTrackingId);
print $response;

# my $msgResponse = $service->sendMessage($msgObj);
# print $msgResponse;