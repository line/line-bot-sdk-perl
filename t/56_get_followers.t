use Test2::V0;
use lib 't/lib';
use t::Util;

use LINE::Bot::API;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

subtest get_with_start_and_limit => sub {
    send_request {
        my $res = $bot->get_followers({ 'start' => 'start_token', 'limit' => 100 });

        isa_ok $res, 'LINE::Bot::API::Response::Followers';
        is $res->is_success, T();
        is $res->http_status, 200;

        is $res->user_ids, [1,2,3];
        is $res->next, U();
    } receive_request {
        my %args = @_;
        is $args{method}, 'GET';
        is $args{url},    'https://api.line.me/v2/bot/followers/ids?limit=100&start=start_token';

        +{
            userIds => [1,2,3]
        }
    };
};

subtest get_with_limit => sub {
    send_request {
        my $res = $bot->get_followers({ 'limit' => 100 });

        isa_ok $res, 'LINE::Bot::API::Response::Followers';
        is $res->is_success, T();
        is $res->http_status, 200;

        is $res->user_ids, [1,2,3];
        is $res->next, U();
    } receive_request {
        my %args = @_;
        is $args{method}, 'GET';
        is $args{url},    'https://api.line.me/v2/bot/followers/ids?limit=100';

        +{
            userIds => [1,2,3]
        }
    };
};

subtest get_with_start => sub {
    send_request {
        my $res = $bot->get_followers({ 'start' => 'start_token'});

        isa_ok $res, 'LINE::Bot::API::Response::Followers';
        is $res->is_success, T();
        is $res->http_status, 200;

        is $res->user_ids, [1,2,3];
        is $res->next, U();
    } receive_request {
        my %args = @_;
        is $args{method}, 'GET';
        is $args{url},    'https://api.line.me/v2/bot/followers/ids?start=start_token';

        +{
            userIds => [1,2,3]
        }
    };
};

subtest get_no_parameter => sub {
    send_request {
        my $res = $bot->get_followers();

        isa_ok $res, 'LINE::Bot::API::Response::Followers';
        is $res->is_success, T();
        is $res->http_status, 200;

        is $res->user_ids, [1,2,3];
        is $res->next, 'next_token';
    } receive_request {
        my %args = @_;
        is $args{method}, 'GET';
        is $args{url},    'https://api.line.me/v2/bot/followers/ids';

        +{
            userIds => [1,2,3],
            next => 'next_token'
        }
    };
};


done_testing;
