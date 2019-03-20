
package Services::EmailService;

use warnings;
use strict;

use Services::ApiHelper;
use Data::Message;
use JSON;
use chilkat();

my $baseURL = "https://api.paubox.net:443/v1/";
my $apiKey = "your-api-key";
my $apiUser = "your-api-user";

sub getEmailDisposition {   
    my ($sourceTrackingId) = @_;        
    my $authHeader =  _getAuthHeader() ;
    my $apiUrl = "/message_receipt?sourceTrackingId=" . $sourceTrackingId;    
    my $response = Services::ApiHelper::callToAPIByGet($baseURL.$apiUser, $apiUrl, $authHeader);
    print $response;
}

sub sendMessage {   
    my ($msgObj) = @_;        
    my $authHeader =  _getAuthHeader() ;
    my $apiUrl = "/messages";    

    

    # my $JSON = JSON->new->utf8;
    # $JSON->convert_blessed(1);

    # my $reqBody = $JSON->encode($msgObj);

    my $reqBody = getJSON($msgObj);

    my $sbReq = chilkat::CkStringBuilder->new();
    $reqBody->EmitSb($sbReq);

    print $reqBody;
    my $response = Services::ApiHelper::callToAPIByPost($baseURL.$apiUser, $apiUrl, $authHeader,$reqBody);
    print $response;
}

sub _getAuthHeader {
    return  "Token token=".$apiKey; 
}

sub getJSON {
    
    my ($msg) = @_;    
    

my $json = chilkat::CkJsonObject->new();
$json->UpdateString("data.message.recipients",$msg->{'to'});
$json->UpdateString("data.message.bcc",$msg->{'bcc'});
$json->UpdateString("data.message.headers.subject",$msg->{'subject'});
$json->UpdateString("data.message.headers.from",$msg->{'from'});
# $json->UpdateString("data.message.headers.reply-to",'Sender Name <sender@authorized_domain.com>');
# $json->UpdateBool("data.message.allowNonTLS",0);
# $json->UpdateString("data.message.content.text/plain","Hello World!");
# $json->UpdateString("data.message.content.text/html","<html><body><h1>Hello World!</h1></body></html>");
# $json->UpdateString("data.message.attachments[0].fileName","hello_world.txt");
# $json->UpdateString("data.message.attachments[0].contentType","text/plain");
# $json->UpdateString("data.message.attachments[0].content","SGVsbG8gV29ybGQh\n");
return $json;
}

1;
