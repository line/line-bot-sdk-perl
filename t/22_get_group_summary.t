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

subtest '#get_group_summary' => sub {
    send_request {
        my $res = $bot->get_group_summary('1234567890');
        ok $res->is_success;
        is $res->http_status, 200;

        is $res->groupId, 1234567890;
        is $res->groupName, 'test_group_name';
        is $res->pictureUrl, 'https://example.com/dummy_url';

        # alias
        is $res->group_id, 1234567890;
        is $res->group_name, 'test_group_name';
        is $res->pictureUrl, 'https://example.com/dummy_url';
    } receive_request {
        my %args = @_;

        is $args{method}, 'GET';
        is $args{url},    'https://api.line.me/v2/bot/group/1234567890/summary';

        + {
            groupId => 1234567890,
            groupName => 'test_group_name',
            pictureUrl => 'https://example.com/dummy_url',
        }
    };
};

done_testing();
