package LINE::Bot::API::Response::Content;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub fh      { $_[0]->{fh} }
sub headers { $_[0]->{headers} }

1;
