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

send_request {
    my $res = $bot->get_number_of_followers({ date => "20200214" });
    ok $res->is_success;
    is $res->http_status, 200;
    is $res->status, "ready";
    is $res->followers, 42;
    is $res->targetedReaches, 12345;
    is $res->blocks, 4321;
} receive_request {
    my %args = @_;
    is $args{method}, 'GET';
    is $args{url},    'https://api.line.me/v2/bot/insight/followers?date=20200214',

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{
        status => "ready",
        followers => 42,
        targetedReaches => 12345,
        blocks => 4321,
    };
};

done_testing;
