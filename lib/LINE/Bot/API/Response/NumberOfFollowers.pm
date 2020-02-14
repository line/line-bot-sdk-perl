package LINE::Bot::API::Response::NumberOfFollowers;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub status  { $_[0]->{status}  }
sub followers  { $_[0]->{followers}  }
sub targetedReaches { $_[0]->{targetedReaches} }
sub blocks { $_[0]->{blocks} }

1;
