use strict;
use warnings;
use utf8;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;
use Carp ();

$SIG{__DIE__} = \&Carp::confess;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

# get_number_of_sent_reply_messages
send_request {
    my $res = $bot->get_number_of_sent_reply_messages('20190126');
    ok $res->is_success;
    is $res->http_status, 200;
    is $res->status, 'ready';
    is $res->success, 495;
} receive_request {
    my %args = @_;
    is $args{method}, 'GET';
    is $args{url},    'https://api.line.me/v2/bot/message/delivery/reply?date=20190126';

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{
        status => 'ready',
        success => 495,
    };
};

# get_number_of_sent_push_messages
send_request {
    my $res = $bot->get_number_of_sent_push_messages('20190126');
    ok $res->is_success;
    is $res->http_status, 200;
    is $res->status, 'ready';
    is $res->success, 495;
} receive_request {
    my %args = @_;
    is $args{method}, 'GET';
    is $args{url},    'https://api.line.me/v2/bot/message/delivery/push?date=20190126';

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{
        status => 'ready',
        success => 495,
    };
};

# get_number_of_sent_multicast_messages
send_request {
    my $res = $bot->get_number_of_sent_multicast_messages('20190126');
    ok $res->is_success;
    is $res->http_status, 200;
    is $res->status, 'ready';
    is $res->success, 495;
} receive_request {
    my %args = @_;
    is $args{method}, 'GET';
    is $args{url},    'https://api.line.me/v2/bot/message/delivery/multicast?date=20190126';

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{
        status => 'ready',
        success => 495,
    };
};

# get_number_of_send_broadcast_messages
send_request {
    my $res = $bot->get_number_of_send_broadcast_messages('20190126');
    ok $res->is_success;
    is $res->http_status, 200;
    is $res->status, 'ready';
    is $res->success, 10000;
} receive_request {
    my %args = @_;
    is $args{method}, 'GET';
    is $args{url},    'https://api.line.me/v2/bot/message/delivery/broadcast?date=20190126';

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{
        status => 'ready',
        success => 10000,
    };
};

done_testing;
