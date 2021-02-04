use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::API;
use Furl;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

subtest download_rich_menu_image => sub {
    send_get_content_request {
        my $res = $bot->download_rich_menu_image('DUMMY_RICH_MENU_ID');
        is $res, 'image binary';
    } receive_request {
        my %args = @_;
        is $args{method}, 'GET';
        is $args{url},    'https://api-data.line.me/v2/bot/richmenu/DUMMY_RICH_MENU_ID/content';

        'image binary';
    }
};

done_testing;
