use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::API;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);
send_request {
    my $res = $bot->get_group_member_profile(
        'GROUP_ID',
        'USER_ID',
    );
    isa_ok $res, 'LINE::Bot::API::Response::GroupMemberProfile';
    ok $res->is_success;
    is $res->http_status, 200;

    is $res->display_name, 'Messaging API';
    is $res->user_id, 'userId';
    is $res->picture_url, 'http://example.com/abcdefghijklmn';
} receive_request {
    my %args = @_;
    is $args{method}, 'GET';
    is $args{url},    'https://api.line.me/v2/bot/group/GROUP_ID/member/USER_ID';

    +{
        displayName   => 'Messaging API',
        userId        => 'userId',
        pictureUrl    => 'http://example.com/abcdefghijklmn',
    };
};

done_testing;

