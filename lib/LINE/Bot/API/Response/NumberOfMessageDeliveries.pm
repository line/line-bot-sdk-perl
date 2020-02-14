package LINE::Bot::API::Response::NumberOfMessageDeliveries;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub status      { $_[0]->{status}  }
sub broadcast   { $_[0]->{broadcast} }
sub targeting   { $_[0]->{targeting} }

1;
