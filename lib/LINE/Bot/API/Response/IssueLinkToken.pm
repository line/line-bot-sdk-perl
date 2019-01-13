package LINE::Bot::API::Response::IssueLinkToken;
use strict;
use warnings;
use utf8;
use parent 'LINE::Bot::API::Response::Common';

sub link_token     { $_[0]->{linkToken} }

1;

