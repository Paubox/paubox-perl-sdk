package Paubox_Email_SDK;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(
                          getEmailDisposition
                          sendMessage                         
                  );

our $VERSION = '1.0';

use Paubox_Email_SDK::ApiHelper;
use Paubox_Email_SDK::Message;

use JSON;
use Config::General;
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
        my $apiHelper =  Paubox_Email_SDK::ApiHelper -> new();  
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
        my $apiHelper =  Paubox_Email_SDK::ApiHelper -> new(); 
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
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Paubox_Email_SDK - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Paubox_Email_SDK;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Paubox_Email_SDK, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

A. U. Thor, E<lt>a.u.thor@a.galaxy.far.far.awayE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by A

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.28.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
