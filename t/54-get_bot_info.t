use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::API;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

my $fake_response = +{
    "userId" => "Ub9952f8...",
    "basicId" => "@216ru...",
    "displayName" => "Example name",
    "pictureUrl" => "https://obs.line-apps.com/...",
    "chatMode" => "chat",
    "markAsReadMode" => "manual"
};

send_request {
    my $res = $bot->get_bot_info();

    isa_ok $res, 'LINE::Bot::API::Response::Common';
    isa_ok $res, 'LINE::Bot::API::Response::BotInfo';

    ok $res->is_success;
    is $res->http_status, 200;

    for my $attr (qw(userId basicId premiumId displayName pictureUrl chatMode markAsReadMode)) {
        ok $res->can($attr);
        is $res->$attr, $fake_response->{$attr};
    }

} receive_request {
    my %args = @_;
    is $args{method}, 'GET';

    is $args{url},    'https://api.line.me/v2/bot/info';

    $fake_response;
};

done_testing;
