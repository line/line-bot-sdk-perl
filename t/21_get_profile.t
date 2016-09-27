use strict;
use warnings;
use Test::More;
use t::Util;

use JSON::XS;
use LINE::Bot::API;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);
send_request {
    my $res = $bot->get_profile(
        'USER_ID',
    );
    ok $res->is_success;
    is $res->http_status, 200;

    is $res->display_name, 'BOT API';
    is $res->user_id, 'userId';
    is $res->picture_url, 'http://example.com/abcdefghijklmn';
    is $res->status_message, 'Hello, LINE!';
} receive_request {
    my %args = @_;
    is $args{method}, 'GET';
    is $args{url},    'https://api.line.me/v2/bot/profile/USER_ID';

    +{
        displayName   => 'BOT API',
        userId        => 'userId',
        pictureUrl    => 'http://example.com/abcdefghijklmn',
        statusMessage => 'Hello, LINE!',
    };
};

done_testing;
