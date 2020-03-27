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

# get_number_of_messages_sent_this_month
send_request {
    my $res = $bot->get_friend_demographics;
    ok $res->is_success;
    is $res->http_status, 200;

    ok $res->available;
    is $res->genders->[0]->{gender}, 'unknown';
    is $res->genders->[0]->{percentage}, 37.6;
    is $res->genders->[1]->{gender}, 'male';
    is $res->genders->[1]->{percentage}, 31.8;
    is $res->genders->[2]->{gender}, 'female';
    is $res->genders->[2]->{percentage}, 30.6;
    is $res->ages->[0]->{age}, 'unknown';
    is $res->ages->[0]->{percentage}, 37.6;
    is $res->ages->[1]->{age}, 'from50';
    is $res->ages->[1]->{percentage}, 17.3;
    is $res->areas->[0]->{area}, 'unknown';
    is $res->areas->[0]->{percentage}, 42.9;
    is $res->areas->[1]->{area}, '徳島';
    is $res->areas->[1]->{percentage}, 2.9;
    is $res->appTypes->[0]->{appType}, 'ios';
    is $res->appTypes->[0]->{percentage}, 62.4;
    is $res->appTypes->[1]->{appType}, 'android';
    is $res->appTypes->[1]->{percentage}, 27.7;
    is $res->appTypes->[2]->{appType}, 'others';
    is $res->appTypes->[2]->{percentage}, 9.9;
    is $res->subscriptionPeriods->[0]->{subscriptionPeriod}, 'over365days';
    is $res->subscriptionPeriods->[0]->{percentage}, 96.4;
    is $res->subscriptionPeriods->[1]->{subscriptionPeriod}, 'within365days';
    is $res->subscriptionPeriods->[1]->{percentage}, 1.9;
    is $res->subscriptionPeriods->[2]->{subscriptionPeriod}, 'within180days';
    is $res->subscriptionPeriods->[2]->{percentage}, 1.2;
    is $res->subscriptionPeriods->[3]->{subscriptionPeriod}, 'within90days';
    is $res->subscriptionPeriods->[3]->{percentage}, 0.5;
    is $res->subscriptionPeriods->[4]->{subscriptionPeriod}, 'within30days';
    is $res->subscriptionPeriods->[4]->{percentage}, 0.1;
    is $res->subscriptionPeriods->[5]->{subscriptionPeriod}, 'within7days';
    is $res->subscriptionPeriods->[5]->{percentage}, 0;
} receive_request {
    my %args = @_;
    is $args{method}, 'GET';
    is $args{url},    'https://api.line.me/v2/bot/insight/demographic';

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{
        available => JSON::XS::true,
        genders => [
            {
                gender => 'unknown',
                percentage => 37.6,
            },
            {
                gender => 'male',
                percentage => 31.8,
            },
            {
                gender => 'female',
                percentage => 30.6
            },
        ],
        ages => [
            {
                age => 'unknown',
                percentage => 37.6,
            },
            {
                age => 'from50',
                percentage => 17.3,
            },
        ],
        areas => [
            {
                area =>  "unknown",
                percentage => 42.9,
            },
            {
                area => "徳島",
                percentage => 2.9,
            },
        ],
        appTypes => [
            {
                appType => 'ios',
                percentage => 62.4,
            },
            {
                appType => 'android',
                percentage => 27.7,
            },
            {
                appType => 'others',
                percentage => 9.9,
            },
        ],
        subscriptionPeriods => [
            {
                subscriptionPeriod => 'over365days',
                percentage => 96.4,
            },
            {
                subscriptionPeriod => 'within365days',
                percentage => 1.9,
            },
            {
                subscriptionPeriod => 'within180days',
                percentage => 1.2,
            },
            {
                subscriptionPeriod => 'within90days',
                percentage => 0.5,
            },
            {
                subscriptionPeriod => 'within30days',
                percentage => 0.1,
            },
            {
                subscriptionPeriod => 'within7days',
                percentage => 0,
            },
        ],
    };
};

done_testing;
