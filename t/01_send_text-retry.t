use strict;
use warnings;
use Test::More;
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
$builder->add_text( text => 'hello!' );

my $DUMMY_RETRY_KEY = '123e4567-e89b-12d3-a456-426614174000';
send_request {
    my $res = $bot->push_message(
        'DUMMY_ID', $builder->build,
        { 'retry_key' => $DUMMY_RETRY_KEY },
    );
    isa_ok $res, 'LINE::Bot::API::Response::Common';
    ok ! $res->is_success;
    is $res->http_status, 409;
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

    my $has_header = 0;
    my $has_retry_header = 0;

    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
        $has_retry_header++ if $key eq 'X-Line-Retry-Key' && $value eq $DUMMY_RETRY_KEY;
    }
    is $has_header, 1;
    is $has_retry_header, 1;

    return (409, +{});
};

done_testing;
