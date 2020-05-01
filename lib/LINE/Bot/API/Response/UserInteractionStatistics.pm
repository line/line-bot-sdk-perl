package LINE::Bot::API::Response::UserInteractionStatistics;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub overview  { $_[0]->{overview}  }
sub messages  { $_[0]->{messages}  }
sub clicks    { $_[0]->{clicks} }

1;
