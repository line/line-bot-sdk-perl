use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::API;
use Furl;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

subtest '#get_member_in_group_count' => sub {
    send_request {
        my $res = $bot->get_member_in_group_count('1234567890');
        ok $res->is_success;
        is $res->http_status, 200;

        is $res->count, 100;

    } receive_request {
        my %args = @_;

        is $args{method}, 'GET';
        is $args{url},    'https://api.line.me/v2/bot/group/1234567890/members/count';

        + {
            count => 100,
        }
    };
};

done_testing();
