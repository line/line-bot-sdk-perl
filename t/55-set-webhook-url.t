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

    my $res = $bot->set_webhook_url({ 'endpoint' => $webhook_url });

    isa_ok $res, 'LINE::Bot::API::Response::Common';
    is $res->is_success, T();
    is $res->http_status, 200;
} receive_request {
    my %args = @_;
    is $args{method}, 'PUT';
    is $args{url},    'https://api.line.me/v2/bot/channel/webhook/endpoint';

    +{};
};

done_testing;
