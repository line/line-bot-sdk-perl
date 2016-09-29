package LINE::Bot::API::Response::Profile;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub display_name   { $_[0]->{displayName} }
sub user_id        { $_[0]->{userId} }
sub picture_url    { $_[0]->{pictureUrl} }
sub status_message { $_[0]->{statusMessage} }

1;
