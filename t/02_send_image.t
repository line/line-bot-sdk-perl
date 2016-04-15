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
    my $res = $bot->send_image(
        to_mid      => 'DUMMY_MID',
        image_url   => 'http://example.com/image.jpg',
        preview_url => 'http://example.com/image_preview.jpg',
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
    is $data->{content}{originalContentUrl}, 'http://example.com/image.jpg';
    is $data->{content}{previewImageUrl}, 'http://example.com/image_preview.jpg';

    is $data->{content}{contentType}, CONTENT_IMAGE;
    is $data->{content}{toType}, TO_USER;

    +{
        timestamp    => 1347940533207,
    };
};

done_testing;
