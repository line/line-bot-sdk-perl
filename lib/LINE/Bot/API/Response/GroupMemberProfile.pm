package LINE::Bot::API::Response::GroupMemberProfile;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub display_name   { $_[0]->{displayName} }
sub user_id        { $_[0]->{userId} }
sub picture_url    { $_[0]->{pictureUrl} }

1;

