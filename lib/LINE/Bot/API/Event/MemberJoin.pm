package LINE::Bot::API::Event::MemberJoin;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

sub is_member_join_event { 1 }

1;
