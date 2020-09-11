use Test2::V0;

use lib 't/lib';
use t::Util;

use JSON::XS;
use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

## This test case is to check parameter for some function of add_blahblah.
subtest '#add_text' => sub {
    subtest 'no sender' => sub {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_text( text => 'hello!' );

        send_request {
            my $res = $bot->push_message('DUMMY_ID', $builder->build);
            isa_ok $res, 'LINE::Bot::API::Response::Common';
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
            is $message->{type}, 'text';
            is $message->{text}, 'hello!';
            is $message->{sender}, undef;

            my $has_header = 0;
            my @headers = @{ $args{headers} };
            while (my($key, $value) = splice @headers, 0, 2) {
                $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
            }
            is $has_header, 1;

            +{};
        };
    };
    
    subtest 'give sender' => sub {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_text( text => 'hello!', sender => 'dummy_sender');

        send_request {
            my $res = $bot->push_message('DUMMY_ID', $builder->build);
            isa_ok $res, 'LINE::Bot::API::Response::Common';
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
            is $message->{type}, 'text';
            is $message->{text}, 'hello!';
            is $message->{sender}, 'dummy_sender';

            my $has_header = 0;
            my @headers = @{ $args{headers} };
            while (my($key, $value) = splice @headers, 0, 2) {
                $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
            }
            is $has_header, 1;

            +{};
        };
    };
};

subtest '#add_image' => sub {
    subtest 'give no sender' => sub {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_image(
            image_url   => 'http://example.com/image.jpg',
            preview_url => 'http://example.com/image_preview.jpg',
        );

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
            is $message->{type}, 'image';
            is $message->{originalContentUrl}, 'http://example.com/image.jpg';
            is $message->{previewImageUrl}, 'http://example.com/image_preview.jpg';
            is $message->{sender}, undef;

            my $has_header = 0;
            my @headers = @{ $args{headers} };
            while (my($key, $value) = splice @headers, 0, 2) {
                $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
            }
            is $has_header, 1;

            +{};
        };
    };

    subtest 'give sender' => sub {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_image(
            image_url   => 'http://example.com/image.jpg',
            preview_url => 'http://example.com/image_preview.jpg',
            sender      => 'dummy_sender',
        );

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
            is $message->{type}, 'image';
            is $message->{originalContentUrl}, 'http://example.com/image.jpg';
            is $message->{previewImageUrl}, 'http://example.com/image_preview.jpg';
            is $message->{sender}, 'dummy_sender';

            my $has_header = 0;
            my @headers = @{ $args{headers} };
            while (my($key, $value) = splice @headers, 0, 2) {
                $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
            }
            is $has_header, 1;

            +{};
        };
    };
};

subtest '#add_video' => sub {
    subtest 'give no sender' => sub {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_video(
            video_url   => 'http://example.com/image.mp4',
            preview_url => 'http://example.com/image_preview.jpg',
        );

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
            is $message->{type}, 'video';
            is $message->{originalContentUrl}, 'http://example.com/image.mp4';
            is $message->{previewImageUrl}, 'http://example.com/image_preview.jpg';
            is $message->{sender}, undef;

            my $has_header = 0;
            my @headers = @{ $args{headers} };
            while (my($key, $value) = splice @headers, 0, 2) {
                $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
            }
            is $has_header, 1;

            +{};
        };
    };

    subtest 'give sender' => sub {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_video(
            video_url   => 'http://example.com/image.mp4',
            preview_url => 'http://example.com/image_preview.jpg',
            sender      => 'dummy_sender',
        );

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
            is $message->{type}, 'video';
            is $message->{originalContentUrl}, 'http://example.com/image.mp4';
            is $message->{previewImageUrl}, 'http://example.com/image_preview.jpg';
            is $message->{sender}, 'dummy_sender';

            my $has_header = 0;
            my @headers = @{ $args{headers} };
            while (my($key, $value) = splice @headers, 0, 2) {
                $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
            }
            is $has_header, 1;

            +{};
        };
    };
};

subtest '#add_audio' => sub {
    subtest 'give no sender' => sub {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_audio(
            audio_url => 'http://example.com/image.mp4',
            duration  => 12_000,
        );

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
            is $message->{type}, 'audio';
            is $message->{originalContentUrl}, 'http://example.com/image.mp4';
            is $message->{duration}, 12_000;
            is $message->{sender}, undef;

            my $has_header = 0;
            my @headers = @{ $args{headers} };
            while (my($key, $value) = splice @headers, 0, 2) {
                $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
            }
            is $has_header, 1;

            +{};
        };
    };

    subtest 'give sender' => sub {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_audio(
            audio_url => 'http://example.com/image.mp4',
            duration  => 12_000,
            sender    => 'dummy_sender',
        );

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
            is $message->{type}, 'audio';
            is $message->{originalContentUrl}, 'http://example.com/image.mp4';
            is $message->{duration}, 12_000;
            is $message->{sender}, 'dummy_sender';

            my $has_header = 0;
            my @headers = @{ $args{headers} };
            while (my($key, $value) = splice @headers, 0, 2) {
                $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
            }
            is $has_header, 1;

            +{};
        };
    };
};

subtest '#add_location' => sub {
    subtest 'give no sender' => sub {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_location(
            title      => 'location label',
            address    => 'tokyo shibuya-ku',
            latitude   => -35.10,
            longitude  => 139.10,
        );

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
            is $message->{type}, 'location';
            is $message->{title}, 'location label';
            is $message->{address}, 'tokyo shibuya-ku';
            is $message->{latitude}, -35.10;
            is $message->{longitude}, 139.10;
            is $message->{sender}, undef;

            my $has_header = 0;
            my @headers = @{ $args{headers} };
            while (my($key, $value) = splice @headers, 0, 2) {
                $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
            }
            is $has_header, 1;

            +{};
        };
    };

    subtest 'give sender' => sub {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_location(
            title      => 'location label',
            address    => 'tokyo shibuya-ku',
            latitude   => -35.10,
            longitude  => 139.10,
            sender     => 'dummy_sender',
        );

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
            is $message->{type}, 'location';
            is $message->{title}, 'location label';
            is $message->{address}, 'tokyo shibuya-ku';
            is $message->{latitude}, -35.10;
            is $message->{longitude}, 139.10;
            is $message->{sender}, 'dummy_sender';

            my $has_header = 0;
            my @headers = @{ $args{headers} };
            while (my($key, $value) = splice @headers, 0, 2) {
                $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
            }
            is $has_header, 1;

            +{};
        };
    };
};

subtest '#add_sticker' => sub {
    subtest 'give no sender' => sub {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_sticker(
            package_id => '1',
            sticker_id => '2',
        );

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
            is $message->{type}, 'sticker';
            is $message->{packageId}, '1';
            is $message->{stickerId}, '2';
            is $message->{sender}, undef;

            my $has_header = 0;
            my @headers = @{ $args{headers} };
            while (my($key, $value) = splice @headers, 0, 2) {
                $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
            }
            is $has_header, 1;

            +{};
        };
    };

    subtest 'give sender' => sub {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_sticker(
            package_id => '1',
            sticker_id => '2',
            sender     => 'dummy_sender',
        );

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
            is $message->{type}, 'sticker';
            is $message->{packageId}, '1';
            is $message->{stickerId}, '2';
            is $message->{sender}, 'dummy_sender';

            my $has_header = 0;
            my @headers = @{ $args{headers} };
            while (my($key, $value) = splice @headers, 0, 2) {
                $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
            }
            is $has_header, 1;

            +{};
        };
    };
};

done_testing;
