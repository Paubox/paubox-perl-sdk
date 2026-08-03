use strict;
use warnings;

use Test::More;

#
# Network-free unit test for Paubox_Email_SDK::_convertMsgObjtoJSONReqObj.
#
# Unlike t/Paubox_Email_SDK.t, this file talks to nothing: it builds
# Paubox_Email_SDK::Message objects in memory and inspects the JSON request
# body that would have been posted. No config.cfg, credentials or network
# access are needed.
#
# Paubox_Email_SDK pulls in several CPAN dependencies at compile time, so
# skip the whole file rather than fail hard when they are not installed.
#
BEGIN {
    foreach my $module (
        qw(JSON Config::General TryCatch String::Util MIME::Base64 REST::Client)
      )
    {
        eval "require $module; 1"
          or plan skip_all => "$module is not installed";
    }
}

use lib 'lib';
use JSON;
use MIME::Base64;

require Paubox_Email_SDK;
require Paubox_Email_SDK::Message;

my $htmlContent = '<html><body><h1>Hello World!</h1></body></html>';

sub buildMessage {
    my (%overrides) = @_;
    return new Paubox_Email_SDK::Message(
        'from' => 'sender@domain.com',
        'replyTo' => 'replyto@domain.com',
        'to' => ['recipient@example.com'],
        'cc' => ['cc@example.com'],
        'bcc' => ['bcc@example.com'],
        'subject' => 'Testing!',
        'allowNonTLS' => 0,
        'text_content' => 'Hello World!',
        %overrides
    );
}

sub payloadFor {
    my (%overrides) = @_;
    my $json = Paubox_Email_SDK::_convertMsgObjtoJSONReqObj( buildMessage(%overrides) );
    return ( $json, decode_json($json) -> {'data'} -> {'message'} );
}

#
# Field mapping
#
{
    my ( $json, $message ) = payloadFor( 'html_content' => $htmlContent );

    is_deeply( $message -> {'recipients'}, ['recipient@example.com'], 'to maps to recipients' );
    is_deeply( $message -> {'cc'}, ['cc@example.com'], 'cc is passed through' );
    is_deeply( $message -> {'bcc'}, ['bcc@example.com'], 'bcc is passed through' );
    is( $message -> {'headers'} -> {'subject'}, 'Testing!', 'subject moves into headers' );
    is( $message -> {'headers'} -> {'from'}, 'sender@domain.com', 'from moves into headers' );
    is( $message -> {'headers'} -> {'reply-to'}, 'replyto@domain.com', 'replyTo maps to reply-to header' );
    is( $message -> {'allowNonTLS'}, 0, 'allowNonTLS is passed through' );
    is( $message -> {'content'} -> {'text/plain'}, 'Hello World!', 'text_content maps to text/plain' );
    is_deeply( $message -> {'attachments'}, [], 'attachments default to an empty list' );
}

#
# html_content is base64 encoded, and left undefined when absent
#
{
    my ( $json, $message ) = payloadFor( 'html_content' => $htmlContent );
    my $encoded = $message -> {'content'} -> {'text/html'};

    unlike( $encoded, qr/\s/, 'encoded html content is trimmed of whitespace' );
    is( decode_base64($encoded), $htmlContent, 'html_content is base64 encoded' );
}

{
    my ( $json, $message ) = payloadFor();
    ok( exists $message -> {'content'} -> {'text/html'}, 'text/html key is still present without html_content' );
    is( $message -> {'content'} -> {'text/html'}, undef, 'text/html is null without html_content' );
}

#
# attachments are passed through untouched
#
{
    my $attachments = [
        {
            'fileName' => 'sample.pdf',
            'contentType' => 'application/pdf',
            'content' => 'JVBERi0xLjMKJcTl8uXrp/Og0MTGCg=='
        }
    ];
    my ( $json, $message ) = payloadFor( 'attachments' => $attachments );
    is_deeply( $message -> {'attachments'}, $attachments, 'attachments are passed through untouched' );
}

#
# forceSecureNotification. The key must be absent from the payload entirely
# whenever the value was not explicitly true or false -- not null, not "".
#
my @absentCases = (
    [ 'unset', undef ],
    [ 'empty string', '' ],
    [ 'unrecognised value', 'garbage' ],
);

foreach my $case (@absentCases) {
    my ( $label, $value ) = @{$case};
    my ( $json, $message ) = payloadFor( 'forceSecureNotification' => $value );

    ok( !exists $message -> {'forceSecureNotification'},
        "forceSecureNotification key is absent ($label)" );
    unlike( $json, qr/forceSecureNotification/,
        "forceSecureNotification does not appear in the JSON at all ($label)" );
}

my @presentCases = (
    [ 'true', 'true', 1 ],
    [ 'TRUE', 'TRUE', 1 ],
    [ 'padded true', ' true ', 1 ],
    [ 'false', 'false', 0 ],
    [ 'FALSE', 'FALSE', 0 ],
);

foreach my $case (@presentCases) {
    my ( $label, $value, $expected ) = @{$case};
    my ( $json, $message ) = payloadFor( 'forceSecureNotification' => $value );

    ok( exists $message -> {'forceSecureNotification'},
        "forceSecureNotification key is present ($label)" );
    is( $message -> {'forceSecureNotification'}, $expected,
        "forceSecureNotification is $expected ($label)" );
    like( $json, qr/"forceSecureNotification":$expected[,}]/,
        "forceSecureNotification is an unquoted number in the JSON ($label)" );
}

done_testing();
