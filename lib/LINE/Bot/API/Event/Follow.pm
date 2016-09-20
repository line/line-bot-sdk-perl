package LINE::Bot::API::Event::Follow;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

sub is_follow_event { 1 }

1;
