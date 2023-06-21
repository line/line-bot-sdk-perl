package LINE::Bot::API::Event::VideoViewingComplete;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

sub is_video_viewing_complete_event { 1 }

sub tracking_id { $_[0]->{videoPlayComplete}{trackingId} }

1;
