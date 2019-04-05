use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use JSON::XS qw(decode_json);
use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

my $fake_rich_menu = decode_json(<<'JSON');
{
  "richMenuId": "{richMenuId}",
  "size": {
    "width": 2500,
    "height": 1686
  },
  "selected": false,
  "name": "Nice richmenu",
  "chatBarText": "Tap to open",
  "areas": [
    {
      "bounds": {
        "x": 0,
        "y": 0,
        "width": 2500,
        "height": 1686
      },
      "action": {
        "type": "postback",
        "label":"Buy",
        "data": "action=buy&itemid=123"
      }
    }
  ]
}
JSON


subtest create_rich_menu => sub {
    # The same rich_menu objcet seen in the curl example from: https://developers.line.biz/en/reference/messaging-api/#rich-menu-object
    my $rich_menu = decode_json('{
        "size": {
          "width": 2500,
          "height": 1686
        },
        "selected": false,
        "name": "Nice richmenu",
        "chatBarText": "Tap here",
        "areas": [
          {
            "bounds": {
              "x": 0,
              "y": 0,
              "width": 2500,
              "height": 1686
            },
            "action": {
              "type": "postback",
              "data": "action=buy&itemid=123"
            }
          }
       ]
    }');

    send_request {
        my $res = $bot->create_rich_menu( $rich_menu );
        ok $res->is_success;
        is $res->http_status, 200;
        is $res->rich_menu_id, '333fakemenuId';
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/bot/richmenu';

        my $has_header = 0;
        my @headers = @{ $args{headers} };
        while (my($key, $value) = splice @headers, 0, 2) {
            $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
        }
        is $has_header, 1;

        return +{
            richMenuId => '333fakemenuId',
        };
    };
};

subtest get_rich_menu_list => sub {
    send_request {
        my $res = $bot->get_rich_menu_list();
        ok $res->is_success;
        is $res->http_status, 200;
        is  0+@{ $res->richmenus }, 1 ;
    } receive_request {
        my %args = @_;
        is $args{method}, 'GET';
        is $args{url},    'https://api.line.me/v2/bot/richmenu/list';

        my $has_header = 0;
        my @headers = @{ $args{headers} };
        while (my($key, $value) = splice @headers, 0, 2) {
            $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
        }
        is $has_header, 1;

        return +{
            richmenus => [ $fake_rich_menu ]
        };
    };
};

done_testing;
