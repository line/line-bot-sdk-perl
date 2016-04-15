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
    my $res = $bot->send_audio(
        to_mid    => 'DUMMY_MID',
        audio_url => 'http://example.com/image.au',
        duration  => 3601,
    );
    is $res->http_status, 200;
    is $res->timestamp, '1347940533207';
    ok $res->is_success;
} receive_request {
    my %args = @_;
    is $args{method}, 'POST';
    is $args{url},    'https://trialbot-api.line.me/v1/events';

    my $data = decode_json $args{content};
    is_deeply $data->{to}, ['DUMMY_MID'];
    is $data->{content}{originalContentUrl}, 'http://example.com/image.au';
    is $data->{content}{contentMetadata}{AUDLEN}, 3601;

    is $data->{content}{contentType}, CONTENT_AUDIO;
    is $data->{content}{toType}, TO_USER;

    +{
        timestamp    => 1347940533207,
    };
};

done_testing;
