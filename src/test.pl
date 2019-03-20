#!/usr/bin/perl
use strict;
use warnings;
use JSON;

use Services::EmailService;
use Data::Message;

my $att = '[{
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
my @decoded_json = @{decode_json($att)};

my $msgObj = new Data::Message(
    'renee@test.com',
    'renee@test.com',
    ['vighneshtrivedi2004@gmail.com'],
    '',
    'Testing from Perl API',
    0, #false
    'This is a Test email',
    '',
    @decoded_json,
    );

my $msgResponse = Services::EmailService::sendMessage($msgObj);
print $msgResponse;
#my $sourceTrackingId ='283911b2-da62-435c-b540-4517048b1b91';
#my $response = Services::EmailService::getEmailDisposition($sourceTrackingId);
