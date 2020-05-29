use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::Message::Narrowcast;
use Furl;
use JSON::XS;

my $bot = LINE::Bot::Message::Narrowcast->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

subtest '#send_message' => sub {
    my $content_type = 'application/json';

    # this parameter is from https://developers.line.biz/ja/reference/messaging-api/#send-narrowcast-message
    send_request {
        my $res = $bot->send_message(
            [
                {
                    type => 'text',
                    text => 'test message',
                }
            ],
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
        );
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url}, 'https://api.line.me/v2/bot/message/narrowcast';

        my %headers = @{ $args{headers} };
        is $headers{'Content-Type'}, 'application/json';

        my $content = decode_json($args{content});
        eq_hash $content, {
            messages => [{
                type => 'text',
                text => 'test message',
            }],
            recipient => {
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
            filter => {
                demographic => {
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
                }
            },
            limit => {
                max => 100,
            },
        };

        +{};
    }
};

done_testing();
