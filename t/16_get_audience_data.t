use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::Audience;
use Furl;
use JSON::XS;

my $bot = LINE::Bot::Audience->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

subtest '#get_audience_data' => sub {
    my $content_type = 'application/json';

    send_request {
        my $res = $bot->get_audience_data({
            audienceGroupId => 12345678,
        });
        ok $res->is_success;
        is $res->http_status, 200;

        is $res->audience_group_id, '12345678';
        is $res->audienceGroupId, '12345678';
        is $res->type, 'UPLOAD';
        is $res->description, 'sample text';
        is $res->status, 'READY';
        is $res->audience_count, 100;
        is $res->audienceCount, 100;
        is $res->created, 1587727997;
        ok $res->is_ifa_audience;
        ok $res->isIfaAudience;
        is $res->permission, 'READ';
        is $res->create_route, 'MESSAGING_API';
        is $res->createRoute, 'MESSAGING_API';
        my @jobs = $res->jobs;
        is $jobs[0]->{audienceGroupJobId}, 12345;
        is $jobs[0]->{audienceGroupId}, 12345678;
        is $jobs[0]->{description}, 'sample text';
        is $jobs[0]->{type}, 'DIFF_ADD';
        is $jobs[0]->{jobStatus}, 'WORKING';
        is $jobs[0]->{audienceCount}, 123;
        is $jobs[0]->{created}, 1587727997;
    } receive_request {
        my %args = @_;
        is $args{method}, 'GET';
        is $args{url}, 'https://api.line.me/v2/bot/audienceGroup/12345678';

        +{
            audienceGroupId => '12345678',
            type => 'UPLOAD',
            description => 'sample text',
            status => 'READY',
            audienceCount => 100,
            created => 1587727997,
            isIfaAudience => JSON::XS::true,
            permission => 'READ',
            createRoute => 'MESSAGING_API',
            jobs => ({
                audienceGroupJobId => 12345,
                audienceGroupId => 12345678,
                description => 'sample text',
                type => 'DIFF_ADD',
                jobStatus => 'WORKING',
                audienceCount => 123,
                created => 1587727997,
            }),
        }
    }
};

done_testing();
