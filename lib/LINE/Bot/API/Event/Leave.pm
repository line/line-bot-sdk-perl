package LINE::Bot::API::Event::Leave;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

sub is_leave_event { 1 }

1;
