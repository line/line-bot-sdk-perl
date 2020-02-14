use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use JSON::XS qw(decode_json);
use LINE::Bot::API;
use Furl;
use Data::Dumper 'Dumper';

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

subtest upload_rich_menu_image => sub {
    my $contentType = 'image/jpeg';
    my $imagePath = 't/controller-rich-menu-image-sample.jpg';

    send_request {
        my $res = $bot->upload_rich_menu_image('DUMMY_RICH_MENU_ID', $contentType, $imagePath);
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api-data.line.me/v2/bot/richmenu/DUMMY_RICH_MENU_ID/content';

        my %headers = @{ $args{headers} };
        is $headers{'Content-Type'}, 'image/jpeg';

        +{};
    }
};

done_testing;
