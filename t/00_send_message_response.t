use strict;
use warnings;
use Test::More;
use t::Util;

use JSON::XS;
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
        my $res = $bot->push_message('DUMMY_MID', $builder->build);
        isa_ok $res, 'LINE::Bot::API::Response::Common';
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        +{};
    };
};

done_testing;
