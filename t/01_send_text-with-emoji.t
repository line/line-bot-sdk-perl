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

my $builder = LINE::Bot::API::Builder::SendMessage->new;

# The example from https://developers.line.biz/en/reference/messaging-api/#text-message
$builder->add_text(
    text => '$ LINE emoji $',
    emojis => [
        +{
            "index" => 0,
            "productId" => "5ac1bfd5040ab15980c9b435",
            "emojiId" => "001"
        },
        +{
            "index" => 13,
            "productId" => "5ac1bfd5040ab15980c9b435",
            "emojiId" => "002"
        }
    ]
);

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
    is $message->{text}, '$ LINE emoji $';
    ok defined($message->{emojis});
    is ref($message->{emojis}), 'ARRAY';
    is ((0+ @{$message->{emojis}}), 2);

    for my $emoji (@{$message->{emojis}}) {
        is 0+keys(%$emoji), 3;
        ok defined($emoji->{index});
        ok defined($emoji->{productId});
        ok defined($emoji->{emojiId});
    }

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
    isa_ok $res, 'LINE::Bot::API::Response::Common';
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
    is $message->{type}, 'text';
    ok defined( $message->{emojis} );

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{};
};

done_testing;
