package LINE::Bot::API::Response::Followers;
use strict;
use warnings;
use utf8;
use parent 'LINE::Bot::API::Response::Common';

sub user_ids { $_[0]->{userIds} }
sub next { $_[0]->{next} }

1;
