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

    my $res = $bot->rich_message(
        height => 1040,
    )->set_action(
        MANGA => (
            text     => 'manga',
            link_uri => 'https://example.com/family/manga/en',
        ),
    )->add_listener(
        action => 'MANGA',
        x      => 0,
        y      => 0,
        width  => 520,
        height => 520,
    )->send_message(
        to_mid    => 'DUMMY_MID',,
        image_url => 'https://example.com/rich-image/foo',
        alt_text  => 'This is a alt text.',
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
    is $data->{eventType}, '138311608800106203';
    is_deeply $data->{to}, ['DUMMY_MID'];

    is $data->{content}{contentMetadata}{ALT_TEXT}, 'This is a alt text.';
    is $data->{content}{contentMetadata}{DOWNLOAD_URL}, 'https://example.com/rich-image/foo';

    my $json = $data->{content}{contentMetadata}{MARKUP_JSON};
    like $json, qr!"linkUri":"https://example.com/family/manga/en"!;
    like $json, qr!"MANGA":\{!;
    like $json, qr!"action":"MANGA"!;

    is_deeply(decode_json($json), {
        'scenes' => {
            'scene1' => {
                'listeners' => [
                    {
                        'params' => [
                            0,
                            0,
                            520,
                            520
                        ],
                        'type' => 'touch',
                        'action' => 'MANGA'
                    }
                ],
                'draws' => [
                    {
                        'image' => 'image1',
                        'x' => 0,
                        'y' => 0,
                        'w' => 1040,
                        'h' => 1040,
                    }
                ]
            }
        },
        'images' => {
            'image1' => {
                'x' => 0,
                'y' => 0,
                'w' => 1040,
                'h' => 1040,
            }
        },
        'actions' => {
            'MANGA' => {
                'text' => 'manga',
                'params' => {
                    'linkUri' => 'https://example.com/family/manga/en'
                },
                'type' => 'web'
            }
        },
        'canvas' => {
            'initialScene' => 'scene1',
            'width' => 1040,
            'height' => 1040,
        }
    });

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
