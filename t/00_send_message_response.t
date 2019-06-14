use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

my $builder = LINE::Bot::API::Builder::SendMessage->new;
$builder->add_text( text => 'hello!' );

subtest 'success' => sub {
    send_request {
        my $res = $bot->push_message('DUMMY_ID', $builder->build);
        isa_ok $res, 'LINE::Bot::API::Response::Common';
        ok $res->is_success;
        is $res->http_status, 200;
        is $res->x_line_request_id, 'dummy_id';
    } receive_request {
        +{};
    };
};

subtest 'fail' => sub {
    send_request {
        my $res = $bot->push_message('DUMMY_ID', $builder->build);
        isa_ok $res, 'LINE::Bot::API::Response::Error';
        ok !$res->is_success;
        is $res->http_status, 500;

        is $res->message, 'ISE';
        is_deeply $res->details, [ +{ message => 'detail message' } ];
    } receive_request {
        +{
            http_status => 500,
            message     => 'ISE',
            details     => [
                +{ message => 'detail message' }
            ],
        };
    };
};

done_testing;
