package LINE::Bot::API::Event::Unsend;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

sub is_unsend_event { 1 }

sub message_id { $_[0]->{unsend}{messageId} }

1;
