
package Services::ApiHelper;

use warnings;
use strict;

use REST::Client;
use JSON;
# Data::Dumper makes it easy to see what the JSON returned actually looks like 
# when converted into Perl data structures.
use Data::Dumper;

sub callToAPIByGet {

        my ($baseUrl, $apiUrl, $authHeader) = @_;

        my $client = REST::Client->new();
        my $headers = {Accept => 'application/json', Authorization => $authHeader};
        
        $client->setHost($baseUrl);
        $client->GET(
            $apiUrl,
            $headers
        );   
        return $client->responseContent();
}

sub callToAPIByPost {

        my ($baseUrl, $apiUrl, $authHeader,$reqBody) = @_;

        my $client = REST::Client->new();

        $client->addHeader('Content-Type', 'application/json');
        $client->addHeader('Authorization', $authHeader);
        $client->addHeader('Accept', 'application/json');
        
        print $reqBody;
        $client->setHost($baseUrl);
        $client->POST(
            $apiUrl,
            '{data:empty}'
        );   
        return $client->responseContent();
}

1;
