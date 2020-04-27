use strict;
use warnings;
use utf8;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;
use JSON::XS;
use Carp ();

$SIG{__DIE__} = \&Carp::confess;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

# get_user_interaction_statistics
send_request {
    my $res = $bot->get_user_interaction_statistics({ requestId => 'f70dd685-499a-4231-a441-f24b8d4fba21' });
    ok $res->is_success;
    is $res->http_status, 200;

    is $res->overview->{requestId}, 'f70dd685-499a-4231-a441-f24b8d4fba21';
    is $res->overview->{timestamp}, 1568214000;
    is $res->overview->{delivered}, 32;
    is $res->overview->{uniqueImpression}, 4;
    is $res->overview->{uniqueClick}, undef;
    is $res->overview->{uniqueMediaPlayed}, 2;
    is $res->overview->{uniqueMediaPlayed100Percent}, -1;
    is $res->messages->[0]->{seq}, 1;
    is $res->messages->[0]->{impression}, 18;
    is $res->messages->[0]->{mediaPlayed}, 11;
    is $res->messages->[0]->{mediaPlayed25Percent}, -1;
    is $res->messages->[0]->{mediaPlayed50Percent}, -1;
    is $res->messages->[0]->{mediaPlayed75Percent}, -1;
    is $res->messages->[0]->{mediaPlayed100Percent}, -1;
    is $res->messages->[0]->{uniqueMediaPlayed}, 2;
    is $res->messages->[0]->{uniqueMediaPlayed25Percent}, -1;
    is $res->messages->[0]->{uniqueMediaPlayed50Percent}, -1;
    is $res->messages->[0]->{uniqueMediaPlayed75Percent}, -1;
    is $res->messages->[0]->{uniqueMediaPlayed100Percent}, -1;
    is $res->clicks->[0]->{seq}, 1;
    is $res->clicks->[0]->{url}, 'https://www.yahoo.co.jp/';
    is $res->clicks->[0]->{click}, -1;
    is $res->clicks->[0]->{uniqueClick}, -1;
    is $res->clicks->[0]->{uniqueClickOfRequest}, -1;
    is $res->clicks->[1]->{seq}, 1;
    is $res->clicks->[1]->{url}, 'https://www.google.com/?hl=ja';
    is $res->clicks->[1]->{click}, -1;
    is $res->clicks->[1]->{uniqueClick}, -1;
    is $res->clicks->[1]->{uniqueClickOfRequest}, -1;
} receive_request {
    my %args = @_;
    is $args{method}, 'GET';
    is $args{url},    'https://api.line.me/v2/bot/insight/message/event?requestId=f70dd685-499a-4231-a441-f24b8d4fba21';

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{
        overview => {
            requestId => 'f70dd685-499a-4231-a441-f24b8d4fba21',
            timestamp => 1568214000,
            delivered => 32,
            uniqueImpression => 4,
            uniqueClick => undef,
            uniqueMediaPlayed => 2,
            uniqueMediaPlayed100Percent => -1,
        },
        messages => [
            {
                seq => 1,
                impression => 18,
                mediaPlayed => 11,
                mediaPlayed25Percent => -1,
                mediaPlayed50Percent => -1,
                mediaPlayed75Percent => -1,
                mediaPlayed100Percent => -1,
                uniqueMediaPlayed => 2,
                uniqueMediaPlayed25Percent => -1,
                uniqueMediaPlayed50Percent => -1,
                uniqueMediaPlayed75Percent => -1,
                uniqueMediaPlayed100Percent => -1,
            },
        ],
        clicks => [
            {
                seq => 1,
                url => 'https://www.yahoo.co.jp/',
                click => -1,
                uniqueClick => -1,
                uniqueClickOfRequest => -1,
            },
            {
                seq => 1,
                url => 'https://www.google.com/?hl=ja',
                click => -1,
                uniqueClick => -1,
                uniqueClickOfRequest => -1,
            },
        ],
    };
};

done_testing;
