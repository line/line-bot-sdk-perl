package LINE::Bot::API::Event::AccountLink;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

sub is_account_link_event { 1 }

sub source { $_[0]{source} }

sub replyToken { $_[0]{replyToken} }

sub link { $_[0]{link} }

1;
