
package Services::EmailService;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(getEmailDisposition, sendMessage);

use warnings;
use strict;

use lib "lib";
use lib "extlib";
use Services::ApiHelper;
use Data::Message;

use JSON;
use Config::General;
use Data::Dumper;
use TryCatch;

my $apiKey ="";
my $apiUser="";
my $baseURL = "https://api.paubox.net:443/v1/";

#
# Default Constructor
#
sub new{    
    my $this = {};

    try{ 

        my $conf = Config::General  ->  new(
            -ConfigFile => 'config.cfg',
            -InterPolateVars => 1
        );

        my %config = $conf -> getall;
        if(not defined $config{'apiKey'} or 
            $config{'apiKey'} eq ""        
        ) {
            die "apiKey is missing.";
        }

        if(
            not defined $config{'apiUsername'} or 
            $config{'apiUsername'} eq ""             
        ) {
            die "apiUsername is missing.";
        }
        
        $apiKey = $config{'apiKey'};       
        $apiUser = $config{'apiUsername'};

        bless $this;        

    } catch($err) {
         die "Error: " .$err;
    };
    return $this;  
}

#
# Private methods
#

sub _getAuthHeader {
    return  "Token token=" .$apiKey; 
}

sub _convertMsgObjtoJSONReqObj {
    
    my ($msg) = @_;    

    my %reqObject = (
    data => {
        message => {
            recipients => $msg -> {'to'},
            bcc => $msg -> {'bcc'},
            headers => {
                subject => $msg -> {'subject'},
                from => $msg -> {'from'},
                'reply-to' => $msg -> {'replyTo'}
            },
            allowNonTLS => $msg -> {'allowNonTLS'},
            content => {
                'text/plain' => $msg -> {'plaintext'},
                'text/html' => $msg -> {'htmltext'}
            },
            attachments => $msg -> {'attachments'},
        },
        
    }           
    );
    
    return encode_json (\%reqObject);    
}

#
# Public methods
#


#
# Get Email Disposition
#

sub getEmailDisposition {       
    my ($class,$sourceTrackingId) = @_;    
    my $apiResponseJSON = "";
    try{               
        my $authHeader =  _getAuthHeader() ;
        my $apiUrl = "/message_receipt?sourceTrackingId=" . $sourceTrackingId; 
        my $apiHelper =  Services::ApiHelper -> new();  
        $apiResponseJSON = $apiHelper -> callToAPIByGet($baseURL.$apiUser, $apiUrl, $authHeader);

        # Converting JSON api response to perl
        my $apiResponsePERL = from_json($apiResponseJSON);        

        if (        
            !length $apiResponsePERL -> {'data'} 
            && !length $apiResponsePERL -> {'sourceTrackingId'}  
            && !length $apiResponsePERL -> {'errors'}
        ) 
        {
                die $apiResponseJSON;
        }

        if (
            defined $apiResponsePERL && defined $apiResponsePERL -> {'data'} && defined $apiResponsePERL -> {'data'} -> {'message'}
            && defined $apiResponsePERL -> {'data'} -> {'message'} -> {'message_deliveries'} 
            && (scalar( @{ $apiResponsePERL -> {'data'} -> {'message'} -> {'message_deliveries'} } ) > 0 )         
        ) {      
            foreach my $message_deliveries ( @{ $apiResponsePERL -> {'data'} -> {'message'} -> {'message_deliveries'} } ) {                    

                if( $message_deliveries -> {'status'} -> {'openedStatus'} eq "" ) {  

                    $message_deliveries -> {'status'} -> {'openedStatus'} = "unopened"; 
                    # Converting perl api response back to JSON
                    $apiResponseJSON = to_json($apiResponsePERL);                  
                }
            }               
        }
    } catch($err) {
         die $err;
    };
    
        
    return $apiResponseJSON;
}

#
# Send Email Message
#

sub sendMessage {   
    my ($class,$msgObj) = @_;        
    my $apiResponseJSON = "";
    try{

        my $apiUrl = "/messages";       
        my $reqBody = _convertMsgObjtoJSONReqObj($msgObj);
        my $apiHelper =  Services::ApiHelper -> new(); 
        $apiResponseJSON = $apiHelper -> callToAPIByPost($baseURL.$apiUser, $apiUrl, _getAuthHeader() , $reqBody);        

        # Converting JSON api response to perl
        my $apiResponsePERL = from_json($apiResponseJSON);         

        if (        
            !length $apiResponsePERL -> {'data'} 
            && !length $apiResponsePERL -> {'sourceTrackingId'}  
            && !length $apiResponsePERL -> {'errors'}              
        )  
        {
                die $apiResponseJSON;
        }

    } catch($err) {
         die $err;
    };

    return $apiResponseJSON;    
}

1;
