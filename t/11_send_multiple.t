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

    my $res = $bot->multiple_message->add_text(
        text       => 'hello!',
    )->add_image(
        image_url   => 'http://example.com/image.jpg',
        preview_url => 'http://example.com/image_preview.jpg',
    )->add_video(
        video_url   => 'http://example.com/image.mp4',
        preview_url => 'http://example.com/image_preview.jpg',
    )->add_audio(
        audio_url => 'http://example.com/image.au',
        duration  => 3601,
    )->add_location(
        text       => 'location label',
        address    => 'tokyo shibuya-ku',
        latitude   => '35.61823286112982',
        longitude  => '139.72824096679688',
    )->add_sticker(
        stkid    => 1,
        stkpkgid => 2,
        stkver   => 3,
    )->send_messages(
        to_mid   => 'DUMMY_MID',
    );

    is $res->http_status, 200;
    is $res->version, 1;
    is $res->message_id, '1347940533207';
    is_deeply $res->failed, [];
    is $res->timestamp, '1347940533207';
    ok $res->is_success;
} receive_request {
    my %args = @_;
    is $args{method}, 'POST';
    is $args{url},    'https://trialbot-api.line.me/v1/events';

    my $data = decode_json $args{content};
    is $data->{eventType}, '140177271400161403';
    is_deeply $data->{to}, ['DUMMY_MID'];
    is $data->{content}{messageNotified}, 0;

    subtest 'text' => sub {
        my $content = $data->{content}{messages}[0];
        is $content->{text}, 'hello!';
        is $content->{contentType}, CONTENT_TEXT;
    };
    subtest 'image' => sub {
        my $content = $data->{content}{messages}[1];
        is $content->{originalContentUrl}, 'http://example.com/image.jpg';
        is $content->{previewImageUrl}, 'http://example.com/image_preview.jpg';
        is $content->{contentType}, CONTENT_IMAGE;
    };
    subtest 'video' => sub {
        my $content = $data->{content}{messages}[2];
        is $content->{originalContentUrl}, 'http://example.com/image.mp4';
        is $content->{previewImageUrl}, 'http://example.com/image_preview.jpg';
        is $content->{contentType}, CONTENT_VIDEO;
    };
    subtest 'audio' => sub {
        my $content = $data->{content}{messages}[3];
        is $content->{originalContentUrl}, 'http://example.com/image.au';
        is $content->{contentMetadata}{AUDLEN}, 3601;
        is $content->{contentType}, CONTENT_AUDIO;
    };
    subtest 'location' => sub {
        my $content = $data->{content}{messages}[4];
        is_deeply $data->{to}, ['DUMMY_MID'];
        is_deeply $content->{location}, { title => 'location label', address => 'tokyo shibuya-ku', latitude => '35.61823286112982', longitude => '139.72824096679688' };
        is $content->{text}, 'location label';
        is $content->{contentType}, CONTENT_LOCATION;
    };
    subtest 'sticker' => sub {
        my $content = $data->{content}{messages}[5];
        is_deeply $content->{contentMetadata}, { STKID => 1, STKPKGID => 2, STKVER => 3 };
        is $content->{contentType}, CONTENT_STICKER;
    };

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'X-Line-ChannelID'             && $value eq '1000000000';
        $has_header++ if $key eq 'X-Line-ChannelSecret'         && $value eq 'testsecret';
        $has_header++ if $key eq 'X-Line-Trusted-User-With-ACL' && $value eq 'TEST_MID';
    }
    is $has_header, 3;

    +{
        version   => 1,
        messageId => 1347940533207,
        failed    => [],
        timestamp => 1347940533207,
    };
};

done_testing;
