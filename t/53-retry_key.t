use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;
use LINE::Bot::Message::Narrowcast;

use constant DUMMY_RETRY_KEY => '123e4567-e89b-12d3-a456-426614174000';

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

sub verify_request {
    my %args = @_;
    my $has_header = 0;
    my $has_retry_header = 0;

    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
        $has_retry_header++ if $key eq 'X-Line-Retry-Key' && $value eq DUMMY_RETRY_KEY();
    }
    is $has_header, 1;
    is $has_retry_header, 1;

    return (409, +{});
}

subtest "push_message() with retry_key" => sub {
    send_request {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_text( text => 'hello!' );
        my $res = $bot->push_message(
            'DUMMY_ID', $builder->build,
            { 'retry_key' => DUMMY_RETRY_KEY() },
        );
        isa_ok $res, 'LINE::Bot::API::Response::Common';
        ok ! $res->is_success;
        is $res->http_status, 409;
    } receive_request { verify_request(@_) };
};

subtest "broadcast() with retry_key" => sub {
    my $builder = LINE::Bot::API::Builder::SendMessage->new->add_text( text => 'yo' );
    send_request {
        my $res = $bot->broadcast(
            $builder->build,
            { 'retry_key' => DUMMY_RETRY_KEY() },
        );
        ok ! $res->is_success;
        is $res->http_status, 409;
    } receive_request { verify_request(@_) };
};

subtest "narrowcast() with retry_key" => sub {
    my $bot = LINE::Bot::Message::Narrowcast->new(
        channel_secret       => 'testsecret',
        channel_access_token => 'ACCESS_TOKEN',
    );

    send_request {
        my $res = $bot->send_message(
            # message
            [

                {
                    type => 'text',
                    text => 'test message',
                }
            ],

            # recipient
            {
                type => 'operator',
                and => [
                    {
                        type => 'audience',
                        audienceGroupId => 5614991017776,
                    },
                    {
                        type => 'operator',
                        not => {
                            type => 'audience',
                            audienceGroupId => 4389303728991,
                        },
                    },
                ],
            },

            # demographic
            {
                type => 'operator',
                or => [
                    {
                        type => 'operator',
                        and => [
                            {
                                type => 'gender',
                                oneOf => ['male', 'female'],
                            },
                            {
                                type => 'age',
                                gte => 'age_20',
                                lt => 'age_25',
                            },
                            {
                                type => 'appType',
                                oneOf => ['android', 'ios'],
                            },
                            {
                                type => 'area',
                                oneOf => ['jp_23', 'jp_05'],
                            },
                            {
                                type => 'subscriptionPeriod',
                                gte => 'day_7',
                                lt => 'day_30',
                            },
                        ],
                    },
                    {
                        type => 'operator',
                        and => [
                            {
                                type => 'age',
                                gte => 'age_35',
                                lt => 'age_40',
                            },
                            {
                                type => 'operator',
                                not => {
                                    type => 'gender',
                                    oneOf => ['male'],
                                },
                            },
                        ],
                    },
                ],
            },
            # limit
            5,
            # options
            { 'retry_key' => DUMMY_RETRY_KEY() },
        );

        ok ! $res->is_success;
        is $res->http_status, 409;
    } receive_request { verify_request(@_) };
};

done_testing;
