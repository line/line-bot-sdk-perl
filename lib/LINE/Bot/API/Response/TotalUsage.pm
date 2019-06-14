package LINE::Bot::API::Response::TotalUsage;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub total_usage { $_[0]->{totalUsage} }

1;
