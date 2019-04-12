package LINE::Bot::API::Event::MemberLeave;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

sub is_member_leave_event { 1 }

1;
