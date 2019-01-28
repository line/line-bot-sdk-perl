package LINE::Bot::API::Response::NumberOfSentMessages;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub status  { $_[0]->{status}  }
sub success { $_[0]->{success} }

1;

