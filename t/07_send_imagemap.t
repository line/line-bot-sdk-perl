use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use JSON::XS;
use LINE::Bot::API;
use LINE::Bot::API::Builder::ImagemapMessage;
use LINE::Bot::API::Builder::SendMessage;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

my $imagemap = LINE::Bot::API::Builder::ImagemapMessage->new(
    base_url    => 'http://example.com/imagemap_base',
    alt_text    => 'test map',
    base_width  => 1040,
    base_height => 1040,
)->add_uri_action(
    uri => 'http://example.com/family/manga/en',
    area_x      => 0,
    area_y      => 0,
    area_width  => 1040,
    area_height => 520,
)->add_message_action(
    text        => 'Uranai',
    area_x      => 0,
    area_y      => 520,
    area_width  => 1040,
    area_height => 520,
);

my $builder = LINE::Bot::API::Builder::SendMessage->new->add_imagemap($imagemap->build);

send_request {
    my $res = $bot->push_message('DUMMY_ID', $builder->build);
    ok $res->is_success;
    is $res->http_status, 200;
} receive_request {
    my %args = @_;
    is $args{method}, 'POST';
    is $args{url},    'https://api.line.me/v2/bot/message/push';

    my $data = decode_json $args{content};
    is $data->{to}, 'DUMMY_ID';
    is scalar(@{ $data->{messages} }), 1;
    my $message = $data->{messages}[0];
    is $message->{type}, 'imagemap';
    is $message->{baseUrl}, 'http://example.com/imagemap_base';
    is $message->{altText}, 'test map';
    is $message->{baseSize}{width}, '1040';
    is $message->{baseSize}{height}, '1040';
    is scalar(@{ $message->{actions} }), 2;
    is_deeply $message->{actions}[0], +{
        type => 'uri',
        linkUri => 'http://example.com/family/manga/en',
        area => { x => 0, y => 0, width => 1040, height => 520 },
    };
    is_deeply $message->{actions}[1], +{
        type => 'message',
        text => 'Uranai',
        area => { x => 0, y => 520, width => 1040, height => 520 },
    };

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{};
};

send_request {
    my $res = $bot->reply_message('DUMMY_TOKEN', $builder->build);
    ok $res->is_success;
    is $res->http_status, 200;
} receive_request {
    my %args = @_;
    is $args{method}, 'POST';
    is $args{url},    'https://api.line.me/v2/bot/message/reply';

    my $data = decode_json $args{content};
    is $data->{replyToken}, 'DUMMY_TOKEN';
    is scalar(@{ $data->{messages} }), 1;
    my $message = $data->{messages}[0];
    is $message->{type}, 'imagemap';
    is $message->{baseUrl}, 'http://example.com/imagemap_base';
    is $message->{altText}, 'test map';
    is $message->{baseSize}{width}, '1040';
    is $message->{baseSize}{height}, '1040';
    is scalar(@{ $message->{actions} }), 2;
    is_deeply $message->{actions}[0], +{
        type => 'uri',
        linkUri => 'http://example.com/family/manga/en',
        area => { x => 0, y => 0, width => 1040, height => 520 },
    };
    is_deeply $message->{actions}[1], +{
        type => 'message',
        text => 'Uranai',
        area => { x => 0, y => 520, width => 1040, height => 520 },
    };

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{};
};

send_request {
    my $imagemap = LINE::Bot::API::Builder::ImagemapMessage->new(
        base_url    => 'https://example.com/bot/images/rm001',
        alt_text    => 'this is an imagemap',
        base_width  => 1040,
        base_height => 1040,
        video => {
            originalContentUrl => "https://example.com/video.mp4",
            previewImageUrl => "https://example.com/video_preview.jpg",
            area => {
                x => 0,
                y => 0,
                width => 1040,
                height => 585
            }
        }
    );
    my $builder = LINE::Bot::API::Builder::SendMessage->new->add_imagemap($imagemap->build);

    my $res = $bot->reply_message('DUMMY_TOKEN', $builder->build);
    ok $res->is_success;
    is $res->http_status, 200;
} receive_request {
    my %args = @_;
    is $args{method}, 'POST';
    is $args{url},    'https://api.line.me/v2/bot/message/reply';

    my $data = decode_json $args{content};
    is $data->{replyToken}, 'DUMMY_TOKEN';
    is scalar(@{ $data->{messages} }), 1;
    my $message = $data->{messages}[0];
    is $message->{type}, 'imagemap';
    is $message->{baseUrl}, 'https://example.com/bot/images/rm001';
    is $message->{altText}, 'this is an imagemap';
    is $message->{baseSize}{width}, '1040';
    is $message->{baseSize}{height}, '1040';

    is_deeply $message->{video}, {
        originalContentUrl => "https://example.com/video.mp4",
        previewImageUrl => "https://example.com/video_preview.jpg",
        area => {
            x => 0,
            y => 0,
            width => 1040,
            height => 585
        }
    };

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{};
};

done_testing;
