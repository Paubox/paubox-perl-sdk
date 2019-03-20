
package Services::EmailService;

use warnings;
use strict;

use Services::ApiHelper;
use Data::Message;
use JSON;
use Config::General;

my $conf = Config::General->new(
    -ConfigFile => 'config.cfg',
    -InterPolateVars => 1
);

my %config = $conf->getall;

my $baseURL = "https://api.paubox.net:443/v1/";
my $apiKey = $config{'apiKey'};
my $apiUser = $config{'apiUsername'};


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
    
    my $response = Services::ApiHelper::callToAPIByPost($baseURL.$apiUser, $apiUrl, $authHeader,$reqBody);
    print $response;
}

sub _getAuthHeader {
    return  "Token token=".$apiKey; 
}

sub getJSON {
    
    my ($msg) = @_;    

    my %reqObject = (
    data => {
        message => {
            recipients => $msg->{'to'},
            headers => {
                subject => $msg->{'subject'},
                from => $msg->{'from'},
                'reply-to' => $msg->{'replyTo'}
            },
            allowNonTLS => $msg->{'allowNonTLS'},
            content => {
                'text/plain' => $msg->{'plaintext'}
            },
            attachments => $msg->{'attachments'},
        },
        
    }           
    );
    
    return encode_json (\%reqObject);    
}

1;
