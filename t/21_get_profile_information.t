use strict;
use warnings;
use Test::More;
use t::Util;

use JSON::XS;
use LINE::Bot::API;

my $bot = LINE::Bot::API->new(
    channel_id     => 1000000000,
    channel_secret => 'testsecret',
    channel_mid    => 'TEST_MID',
);
send_request {
    my $res = $bot->get_user_profile(
        'DUMMY_MID_GET_DISPLAY_NAME',
    );
    is $res->{count}, 1;
    is $res->{contacts}[0]{displayName}, 'BOT API';
} receive_request {
    my %args = @_;
    is $args{method}, 'GET';
    is $args{url},    'https://trialbot-api.line.me/v1/profiles?mids=DUMMY_MID_GET_DISPLAY_NAME';

    +{
        contacts => [
            +{
                displayName   => 'BOT API',
                mid           => 'u0047556f2e40dba2456887320ba7c76d',
                pictureUrl    => 'http://example.com/abcdefghijklmn',
                statusMessage => 'Hello, LINE!',
            },
        ],
        count   => 1,
        display => 1,
        start   => 1,
        total   => 1,
    };
};

done_testing;
