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
    my $res = $bot->send_text(
        to_mid     => 'DUMMY_MID',
        text       => 'hello!',
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
    is $data->{content}{text}, 'hello!';

    is $data->{content}{contentType}, CONTENT_TEXT;
    is $data->{content}{toType}, RECIPIENT_USER;

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
