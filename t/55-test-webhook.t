use Test2::V0;
use lib 't/lib';
use t::Util;

use LINE::Bot::API;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);
send_request {
    my $webhook_url = "https://example.com/webhook/" . int(rand(100000000));

    my $res = $bot->test_webhook_endpoint({ 'endpoint' => $webhook_url });

    isa_ok $res, 'LINE::Bot::API::Response::WebhookTest';
    is $res->is_success, T();
    is $res->http_status, 200;

    is $res->success(), T();
    is $res->timestamp(), E();
    is $res->statusCode(), E();
    is $res->reason(), E();
    is $res->detail(), E();

} receive_request {
    my %args = @_;
    is $args{method}, 'POST';
    is $args{url},    'https://api.line.me/v2/bot/channel/webhook/endpoint';

    +{
        success   => 1,
        timestamp => time() * 1000,
        statusCode => 200,
        reason => 'OK',
        detail => '...',
    }
};

done_testing;
