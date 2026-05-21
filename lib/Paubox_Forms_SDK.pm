package Paubox_Forms_SDK;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(
                          getForm
                          submitForm
                  );

our $VERSION = '1.3';

use Paubox_Email_SDK::ApiHelper;

use JSON;
use TryCatch;

my $formsBaseURL = 'https://apx.paubox.com/forms';

#
# Default Constructor (no credentials required — Forms API is public)
#
sub new {
    my $this = {};
    bless $this;
    return $this;
}

#
# Public methods
#

#
# Get Form
# Retrieves a form's metadata, HTML, JSON schema, and CSS by UUID.
#
sub getForm {
    my ($class, $formId) = @_;
    my $apiResponseJSON = "";
    try {
        if ( !defined($formId) || $formId eq "" ) {
            die "formId is required.";
        }

        my $apiUrl = "/public/form_data/" . $formId;
        my $apiHelper = Paubox_Email_SDK::ApiHelper->new();
        $apiResponseJSON = $apiHelper->callToAPIByGet($formsBaseURL, $apiUrl, "");

        my $apiResponsePERL = from_json($apiResponseJSON);

        if (
            !defined $apiResponsePERL->{'id'}
            && !defined $apiResponsePERL->{'errors'}
        ) {
            die $apiResponseJSON;
        }

    } catch($err) {
        die $err;
    };

    return $apiResponseJSON;
}

#
# Submit Form
# Submits form responses with optional file attachments.
# $formData  - hashref of field key/value pairs matching the form schema
# $attachments - optional arrayref of hashrefs with 'name' and 'content' (base64)
#
sub submitForm {
    my ($class, $formId, $formData, $attachments) = @_;
    my $apiResponseJSON = "";
    try {
        if ( !defined($formId) || $formId eq "" ) {
            die "formId is required.";
        }

        if ( !defined($formData) || ref($formData) ne 'HASH' || !%{$formData} ) {
            die "formData is required and must be a non-empty hash reference.";
        }

        my $apiUrl = "/api/forms/" . $formId . "/submissions";

        my %payload = ( 'form_data' => $formData );
        if ( defined($attachments) && ref($attachments) eq 'ARRAY' && @{$attachments} ) {
            $payload{'attachments'} = $attachments;
        }

        my $reqBody = encode_json(\%payload);
        my $apiHelper = Paubox_Email_SDK::ApiHelper->new();
        $apiResponseJSON = $apiHelper->callToAPIByPost($formsBaseURL, $apiUrl, "", $reqBody);

        # 201 Created returns an empty body; treat that as success
        if ( defined($apiResponseJSON) && $apiResponseJSON ne "" ) {
            my $apiResponsePERL = from_json($apiResponseJSON);
            if ( defined $apiResponsePERL->{'errors'} ) {
                die $apiResponseJSON;
            }
        }

    } catch($err) {
        die $err;
    };

    return $apiResponseJSON;
}

1;
__END__

=head1 NAME

Paubox_Forms_SDK - Perl wrapper for the Paubox Forms API (https://www.paubox.com/products/paubox-forms).

=head1 SYNOPSIS

    use strict;
    use warnings;
    use Paubox_Forms_SDK;

    my $forms = Paubox_Forms_SDK->new();

    # Retrieve a form definition
    my $form = $forms->getForm("your-form-uuid");
    print $form;

    # Submit a form response
    my $response = $forms->submitForm(
        "your-form-uuid",
        { first_name => "Jane", last_name => "Doe", email => "jane\@example.com" }
    );

=head1 DESCRIPTION

This is the official Perl wrapper for the Paubox Forms API. The Forms API endpoints
are public — no API key or credentials are required.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 by Paubox Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut
