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

# get_number_of_messages_sent_this_month
send_request {
    my $res = $bot->get_target_limit_for_additional_messages;
    ok $res->is_success;
    is $res->http_status, 200;
    is $res->type, 'limited';
    is $res->value, 1000;
} receive_request {
    my %args = @_;
    is $args{method}, 'GET';
    is $args{url},    'https://api.line.me/v2/bot/message/quota';

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{
        type => 'limited',
        value => 1000,
    };
};

done_testing;
