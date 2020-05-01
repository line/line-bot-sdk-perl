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

subtest '#update_authority_level' => sub {
    my $content_type = 'application/json';

    send_request {
        my $res = $bot->update_authority_level({
            authorityLevel => 'PUBLIC',
        });
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'PUT';
        is $args{url}, 'https://api.line.me/v2/bot/audienceGroup/authorityLevel';

        my %headers = @{ $args{headers} };
        is $headers{'Content-Type'}, 'application/json';

        my $content = decode_json($args{content} // '');
        is $content->{authorityLevel}, 'PUBLIC';

        +{}
    }
};

done_testing();
