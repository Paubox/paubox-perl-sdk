use strict;
use warnings;

package Data::Message;

#constructor
sub new{

  #the package name 'Message' is in the default array @_
  #shift will take package name 'message' and assign it to variable 'class'
  my $class = shift;

  #object
  my $self = {
    'from' => shift,
    'replyTo' => shift,
    'to' => shift,
    'bcc' => shift,
    'subject' => shift,
    'allowNonTLS' => shift,
    'plaintext' => shift,
    'htmltext' => shift,
    'attachments' => shift
  };

  #blessing self to be object in class
  bless $self, $class;

  #returning object from constructor
  return $self;
}

sub TO_JSON { return { %{ shift() } }; }

1;