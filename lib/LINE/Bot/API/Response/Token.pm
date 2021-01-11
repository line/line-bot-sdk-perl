package LINE::Bot::API::Response::Token;
use strict;
use warnings;
use utf8;
use parent 'LINE::Bot::API::Response::Common';

sub access_token { $_[0]->{access_token} }
sub expires_in { $_[0]->{expires_in} }
sub token_type { $_[0]->{token_type} }
sub key_id { $_[0]->{key_id} }

sub key_ids { $_[0]->{key_ids}}

1;
