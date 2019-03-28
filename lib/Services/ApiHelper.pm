package Services::ApiHelper;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(callToAPIByGet, callToAPIByPost);

use warnings;
use strict;

use REST::Client;
use JSON;
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

    my($class, $baseUrl, $apiUrl, $authHeader) = @_;

    my $client = REST::Client -> new();

    $client -> addHeader('Content-Type', 'application/json');
    $client -> addHeader('Authorization', $authHeader);

    $client -> setHost($baseUrl);
    $client -> GET(
        $apiUrl
    );
    return $client -> responseContent();
}

sub callToAPIByPost {

    my($class, $baseUrl, $apiUrl, $authHeader, $reqBody) = @_;

    my $client = REST::Client -> new();

    $client -> addHeader('Content-Type', 'application/json');
    $client -> addHeader('Authorization', $authHeader);
    $client -> addHeader('Accept', 'application/json');

    $client -> setHost($baseUrl);
    $client -> POST(
        $apiUrl,
        $reqBody
    );    
    return $client -> responseContent();
}

1;