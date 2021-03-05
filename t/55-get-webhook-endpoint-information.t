use Test2::V0;
use lib 't/lib';
use t::Util;

use LINE::Bot::API;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);
send_request {
    my $res = $bot->get_webhook_endpoint_information();

    isa_ok $res, 'LINE::Bot::API::Response::WebhookInformation';
    is $res->is_success, T();
    is $res->http_status, 200;

    is $res->endpoint, 'https://example.com/webhook';
    is $res->active, T();
} receive_request {
    my %args = @_;
    is $args{method}, 'GET';
    is $args{url},    'https://api.line.me/v2/bot/channel/webhook/endpoint';

    +{
        endpoint => 'https://example.com/webhook',
        active   => 1,
    }
};

done_testing;
