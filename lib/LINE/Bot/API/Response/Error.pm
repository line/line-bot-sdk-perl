package LINE::Bot::API::Response::Error;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub message { $_[0]->{message} }
sub details { $_[0]->{details} }

1;
