use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use JSON::XS qw(decode_json);
use LINE::Bot::API::Response::RichMenu;

use JSON::XS qw(decode_json);

my $res_json = decode_json(q<{"richMenuId": "333fakeRichMenuID"}>);

my $res = LINE::Bot::API::Response::RichMenu->new(
    http_status => 200,
    %$res_json
);

is $res->rich_menu_id, '333fakeRichMenuID';

done_testing;
