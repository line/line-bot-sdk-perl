package LINE::Bot::API::Response::Count;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub count  { $_[0]->{count} }

1;
