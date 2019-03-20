#!/usr/bin/perl
use strict;
use warnings;


use Services::EmailService;
use Data::Message;


my $msgObj = new Data::Message(
    'renee@test.com',
    'renee@test.com',
    'vighneshtrivedi2004@gmail.com',
    '',
    'Testing from Perl API',
    0, #false
    'This is a Test email',
    '',
    );

my $msgResponse = Services::EmailService::sendMessage($msgObj);
print $msgResponse;
#my $sourceTrackingId ='f0777ce7-bd6b-4a49-ab58-91e0cacbc642';
#my $response = Services::EmailService::getEmailDisposition($sourceTrackingId);
