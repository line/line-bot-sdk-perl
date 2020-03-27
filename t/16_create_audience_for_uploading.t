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

subtest '#create_audience_for_uploading' => sub {
    my $content_type = 'application/json';

    send_request {
        my $res = $bot->create_audience_for_uploading();
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url}, 'https://api.line.me/v2/bot/audienceGroup/upload';

        my %headers = @{ $args{headers} };
        is $headers{'Content-Type'}, 'application/json';

        +{}
    }
};

done_testing();
