package LINE::Bot::API::Response::RichMenuList;
use strict;
use warnings;
use utf8;
use parent 'LINE::Bot::API::Response::Common';

sub richmenus { $_[0]->{richmenus} }

1;

