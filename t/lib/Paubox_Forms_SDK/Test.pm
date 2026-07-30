#
# MANUAL LIVE-INTEGRATION SUITE -- NOT RUN BY `make test`.
#
# This class is deliberately NOT loaded by t/Paubox_Email_SDK.t, because:
#
#   - Every test here makes real network calls against
#     https://apx.paubox.com/forms . There are no mocks or fixtures.
#   - $VALID_FORM_UUID below is a placeholder. Until it is replaced with a
#     real form UUID from your own Paubox account, getForm_Success and
#     submitForm_Success fail 100% of the time.
#   - submitForm_Success creates a real form submission on the form you
#     point it at.
#
# To run it, edit $VALID_FORM_UUID and then invoke it directly:
#
#   perl -Ilib -It/lib -MPaubox_Forms_SDK::Test -e 'Test::Class->runtests'
#
# For a test that runs anywhere with no network and no credentials, see
# t/convertMsgObjtoJSONReqObj.t .
#
package Paubox_Forms_SDK::Test;
use strict;
use warnings;

use Paubox_Forms_SDK;

use JSON;
use Test::More;
use base qw(Test::Class);

# Replace with a real form UUID from your Paubox account to run live tests.
my $VALID_FORM_UUID   = "your-valid-form-uuid-here";
my $INVALID_FORM_UUID = "00000000-0000-0000-0000-000000000000";

sub getForm_Success: Tests(1) {
    print "Executing tests for getForm_Success:\n";

    my $forms = Paubox_Forms_SDK->new();
    my $response = eval { $forms->getForm($VALID_FORM_UUID) };

    if ($@) {
        is('Failure', 'Success', 'Test failed: ' . $@);
        return;
    }

    my $apiResponsePERL = from_json($response);

    if ( defined $apiResponsePERL->{'id'} ) {
        is('Success', 'Success', 'Test passed');
    } else {
        is('Failure', 'Success', 'Test failed: id not present in response');
    }
}

sub getForm_Failure: Tests(1) {
    print "Executing tests for getForm_Failure:\n";

    my $forms = Paubox_Forms_SDK->new();
    my $response = eval { $forms->getForm($INVALID_FORM_UUID) };

    if ($@) {
        # A die on error is also acceptable as failure behaviour
        is('Success', 'Success', 'Test passed: got expected error');
        return;
    }

    my $apiResponsePERL = from_json($response);

    if ( defined $apiResponsePERL->{'errors'} || !defined $apiResponsePERL->{'id'} ) {
        is('Success', 'Success', 'Test passed');
    } else {
        is('Failure', 'Success', 'Test failed: expected error but got success');
    }
}

sub submitForm_Success: Tests(1) {
    print "Executing tests for submitForm_Success:\n";

    my $forms = Paubox_Forms_SDK->new();
    my $response = eval {
        $forms->submitForm(
            $VALID_FORM_UUID,
            { first_name => "Jane", last_name => "Doe", email => "jane\@example.com" }
        );
    };

    if ($@) {
        is('Failure', 'Success', 'Test failed: ' . $@);
        return;
    }

    # 201 returns empty body; empty string or no errors both indicate success
    if ( !defined($response) || $response eq "" ) {
        is('Success', 'Success', 'Test passed: 201 empty body');
    } else {
        my $apiResponsePERL = from_json($response);
        if ( !defined $apiResponsePERL->{'errors'} ) {
            is('Success', 'Success', 'Test passed');
        } else {
            is('Failure', 'Success', 'Test failed: ' . $response);
        }
    }
}

sub submitForm_Failure: Tests(1) {
    print "Executing tests for submitForm_Failure:\n";

    my $forms = Paubox_Forms_SDK->new();

    # Missing formId should die. This guard fires before any HTTP request,
    # so this particular test needs no network access.
    my $response = eval {
        $forms->submitForm( "", { first_name => "Jane" } );
    };

    if ($@) {
        is('Success', 'Success', 'Test passed: got expected error for empty formId');
    } else {
        is('Failure', 'Success', 'Test failed: expected error for empty formId');
    }
}

1;
