package LINE::Bot::API::Event::Unknown;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

sub is_unknown_event { 1 }

1;
