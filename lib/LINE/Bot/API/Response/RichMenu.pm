package LINE::Bot::API::Response::RichMenu;
use strict;
use warnings;
use utf8;
use parent 'LINE::Bot::API::Response::Common';

sub rich_menu_id     { $_[0]->{richMenuId} }

1;

