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

subtest '#create_audience_for_uploading' => sub {
    subtest 'only required paraemter' => sub {
        send_request {
            my $res = $bot->create_audience_for_uploading({
                description => 'sample text',
                isIfaAudience => JSON::XS::false,
            });
            ok $res->is_success;
            is $res->http_status, 200;
        } receive_request {
            my %args = @_;
            is $args{method}, 'POST';
            is $args{url}, 'https://api.line.me/v2/bot/audienceGroup/upload';

            my %headers = @{ $args{headers} };
            is $headers{'Content-Type'}, 'application/json';

            my $content = decode_json($args{content} // '');
            is $content->{description}, 'sample text';
            ok !$content->{isIfaAudience};

            +{}
        };
    };
    
    subtest 'full parameter' => sub {
        send_request {
            my $res = $bot->create_audience_for_uploading({
                description => 'sample text',
                isIfaAudience => JSON::XS::true,
                uploadDescription => 'sample text',
                audiences => [
                    {
                        id => 123,
                    },
                    {
                        id => 124,
                    },
                ],
            });
            ok $res->is_success;
            is $res->http_status, 200;
        } receive_request {
            my %args = @_;
            is $args{method}, 'POST';
            is $args{url}, 'https://api.line.me/v2/bot/audienceGroup/upload';

            my %headers = @{ $args{headers} };
            is $headers{'Content-Type'}, 'application/json';

            my $content = decode_json($args{content} // '');
            is $content->{description}, 'sample text';
            ok $content->{isIfaAudience};
            is $content->{uploadDescription}, 'sample text';
            is @{ $content->{audiences} }, 2;
            is $content->{audiences}->[0]->{id}, 123;
            is $content->{audiences}->[1]->{id}, 124;

            +{}
        };
    };
};

done_testing();
