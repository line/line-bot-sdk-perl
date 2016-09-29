package LINE::Bot::API::Event::Postback;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

sub is_postback_event { 1 }

sub postback_data { $_[0]->{postback}{data} }

1;
