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

# get_number_of_message_deliveries
send_request {
    my $res = $bot->get_number_of_message_deliveries({ date => '20200214' });
    ok $res->is_success;
    is $res->http_status, 200;

    is $res->status, 'ready';
    is $res->broadcast, 5385;
    is $res->targeting, 522;
} receive_request {
    my %args = @_;
    is $args{method}, 'GET';
    use Data::Dumper;
    print Dumper($args{url});
    is $args{url},    'https://api.line.me/v2/bot/insight/message/delivery?date=20200214';

    # this value is example response from LINE developers
    +{
        status => 'ready',
        broadcast => 5385,
        targeting => 522
    };
};

done_testing;
