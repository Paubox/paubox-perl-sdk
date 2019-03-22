
package Services::ApiHelper;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(callToAPIByGet, callToAPIByPost);

use warnings;
use strict;

use REST::Client;
use JSON;
# Data::Dumper makes it easy to see what the JSON returned actually looks like 
# when converted into Perl data structures.
use Data::Dumper;

#
# Default Constructor
#
sub new {
    my $this = {};
    bless $this;  
    return $this
}

sub callToAPIByGet {

        my ($class, $baseUrl, $apiUrl, $authHeader) = @_;

        my $client = REST::Client->new();
        
        $client->addHeader('Content-Type', 'application/json');
        $client->addHeader('Authorization', $authHeader);        
        
        $client->setHost($baseUrl);
        $client->GET(
            $apiUrl            
        );   
        return $client->responseContent();
}

sub callToAPIByPost {

        my ($class, $baseUrl, $apiUrl, $authHeader,$reqBody) = @_;

        my $client = REST::Client->new();

        $client->addHeader('Content-Type', 'application/json');
        $client->addHeader('Authorization', $authHeader);
        $client->addHeader('Accept', 'application/json');
        
        print $reqBody;
        $client->setHost($baseUrl);
        $client->POST(
            $apiUrl,
            $reqBody
        );   
        return $client->responseContent();
}

1;
