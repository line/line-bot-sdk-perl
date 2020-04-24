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

subtest '#get_authority_level' => sub {
    my $content_type = 'application/json';

    send_request {
        my $res = $bot->get_authority_level();
        ok $res->is_success;
        is $res->http_status, 200;

        is $res->authority_level, 'sample_level_text';
        is $res->authorityLevel, 'sample_level_text';

    } receive_request {
        my %args = @_;
        is $args{method}, 'GET';
        is $args{url}, 'https://api.line.me/v2/bot/audienceGroup/authorityLevel';

        +{
            authorityLevel => 'sample_level_text',
        }
    }
};

done_testing();
