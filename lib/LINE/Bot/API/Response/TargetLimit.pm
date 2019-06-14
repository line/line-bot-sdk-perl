package LINE::Bot::API::Response::TargetLimit;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub type  { $_[0]->{type} }
sub value { $_[0]->{value} }

1;
