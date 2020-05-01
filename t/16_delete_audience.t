use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::Audience;
use Furl;

my $bot = LINE::Bot::Audience->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

subtest '#delete_audience' => sub {
    my $content_type = 'application/json';

    send_request {
        my $res = $bot->delete_audience({ audienceGroupId => 12345678 });
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'DELETE';
        is $args{url}, 'https://api.line.me/v2/bot/audienceGroup/12345678';

        +{}
    }
};

done_testing();
