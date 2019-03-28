use strict;
use warnings;

package Data::Message;

# constructor
sub new {

    # the package name 'Message' is in the default array @_
  	# shift will take package name 'message' and assign it to variable 'class'
    my $class = shift;
    
    my $self = bless {
        'from' => '',
        'replyTo' => '',
        'to' => [],
        'bcc' => [],
        'subject' => '',
        'allowNonTLS' => '' || 0,
        'plaintext' => '',
        'htmltext' => '',
        'attachments' => [], 
    @_ }, $class;

    # returning object from constructor
    return $self;
}

1;