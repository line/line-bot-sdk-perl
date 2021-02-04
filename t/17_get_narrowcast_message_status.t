use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::Message::Narrowcast;
use Furl;

my $bot = LINE::Bot::Message::Narrowcast->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

subtest '#get_narrowcast_message_status' => sub {
    my $content_type = 'application/json';

    send_request {
        my $res = $bot->get_narrowcast_message_status(12345);

        ok $res->is_success;
        is $res->http_status, 200;
        is $res->phase, 'waiting';
        is $res->successCount, 100;
        is $res->success_count, 100; # alias
        is $res->failureCount, 0;
        is $res->failure_count, 0; # alias
        is $res->targetCount, 100;
        is $res->target_count, 100; # alias
        is $res->failedDescription, 'sample description';
        is $res->failed_description, 'sample description'; # alias
        is $res->errorCode, 1;
        is $res->error_code, 1;
        is $res->acceptedTime, '2021-01-01T00:00:00.000Z';
        is $res->accepted_time, '2021-01-01T00:00:00.000Z'; # alias
        is $res->completedTime, '2021-01-01T01:23:45.678Z';
        is $res->completed_time, '2021-01-01T01:23:45.678Z'; # alias
    } receive_request {
        my %args = @_;
        is $args{method}, 'GET';
        is $args{url}, 'https://api.line.me/v2/bot/message/progress/narrowcast?requestId=12345';

        +{
            phase => 'waiting',
            successCount => 100,
            failureCount => 0,
            targetCount => 100,
            failedDescription => 'sample description',
            errorCode => 1,
            acceptedTime => '2021-01-01T00:00:00.000Z',
            completedTime => '2021-01-01T01:23:45.678Z'
        }
    }
};

done_testing();
