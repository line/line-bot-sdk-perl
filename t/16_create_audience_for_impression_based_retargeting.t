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

subtest '#create_audience_for_impression_based_retargeting' => sub {
    my $content_type = 'application/json';

    send_request {
        my $res = $bot->create_audience_for_impression_based_retargeting({
            description => 'audienceGroupName',
            requestId => '12222',
        });
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url}, 'https://api.line.me/v2/bot/audienceGroup/imp';

        my %headers = @{ $args{headers} };
        is $headers{'Content-Type'}, 'application/json';

        my $content = decode_json($args{content});
        eq_hash $content, {
            description => 'audienceGroupName',
            requestId => '12222',
        };

        +{
            audienceGroupId => 4389303728991,
            type => 'IMP',
            description => 'test',
            created => 1500351844,
            requestId => 'f70dd685-499a-4231-a441-f24b8d4fba21',
        }
    }
};

done_testing();
