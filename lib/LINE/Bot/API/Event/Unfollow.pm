package LINE::Bot::API::Event::Unfollow;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

sub is_unfollow_event { 1 }

1;
