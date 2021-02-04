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

subtest '#rename_audience' => sub {
    my $content_type = 'application/json';

    send_request {
        my $res = $bot->rename_audience({
            audience_group_id => 12345678,
            description => 'audienceGroupName',
        });
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url}, 'https://api.line.me/v2/bot/audienceGroup/12345678/updateDescription';

        my %headers = @{ $args{headers} };
        is $headers{'Content-Type'}, 'application/json';

        my $content = decode_json($args{content});
        eq_hash $content, {
            description => 'audienceGroupName',
        };

        +{}
    }
};

done_testing();
