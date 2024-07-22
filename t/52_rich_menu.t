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

subtest get_rich_menu => sub {
    send_request {
        my $res = $bot->get_rich_menu('blahblahid');
        ok $res->is_success;
        is $res->http_status, 200;
        is $res->richMenuId, 'blahblahid';
    } receive_request {
        my %args = @_;
        is $args{method}, 'GET';
        is $args{url},    'https://api.line.me/v2/bot/richmenu/blahblahid';
        return +{
            richMenuId => 'blahblahid',
        }
    };
};

subtest delete_rich_menu => sub {
    send_request {
        my $res = $bot->delete_rich_menu('blahblahid');
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'DELETE';
        is $args{url},    'https://api.line.me/v2/bot/richmenu/blahblahid';
        return +{}
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

subtest set_default_rich_menu => sub {
    send_request {
        my $res = $bot->set_default_rich_menu('hehmenuidheh');
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/bot/user/all/richmenu/hehmenuidheh';
        return +{}
    };
};

subtest get_default_rich_menu_id => sub {
    send_request {
        my $res = $bot->get_default_rich_menu_id();
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'GET';
        is $args{url},    'https://api.line.me/v2/bot/user/all/richmenu';
        return +{ richMenuId => "blahblehblueh" }
    };
};

subtest cancel_default_rich_menu => sub {
    send_request {
        my $res = $bot->cancel_default_rich_menu();
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'DELETE';
        is $args{url},    'https://api.line.me/v2/bot/user/all/richmenu';
        return +{ richMenuId => "blahblehblueh" }
    };
};

subtest link_rich_menu_to_user => sub {
    send_request {
        my $res = $bot->link_rich_menu_to_user(42, "SomeRichMenuId");
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/bot/user/42/richmenu/SomeRichMenuId';
        return +{};
    };
};

subtest link_rich_menu_to_multiple_users => sub {
    send_request {
        my $res = $bot->link_rich_menu_to_multiple_users(
            [ 42, 43, 44, 45 ],
            "fake_menu_id",
        );
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/bot/richmenu/bulk/link';

        is_deeply decode_json($args{content}), {
            userIds => [ 42, 43, 44, 45 ],
            richMenuId => "fake_menu_id",
        };

        return +{};
    };
};

subtest get_rich_menu_id_of_user => sub {
    send_request {
        my $res = $bot->get_rich_menu_id_of_user(42);
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'GET';
        is $args{url},    'https://api.line.me/v2/bot/user/42/richmenu';
        return +{ rirchMenuId => "blahblahmehmeh" };
    };
};

subtest unlink_rich_menu_from_user => sub {
    send_request {
        my $res = $bot->unlink_rich_menu_from_user(42);
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'DELETE';
        is $args{url},    'https://api.line.me/v2/bot/user/42/richmenu';
        return +{};
    };
};

subtest unlink_rich_menu_from_multiple_users => sub {
    send_request {
        my $res = $bot->unlink_rich_menu_from_multiple_users([42, 43, 44, 45]);
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/bot/richmenu/bulk/unlink';
        is_deeply decode_json($args{content}), {
            userIds => [42, 43, 44, 45]
        };
        return +{};
    };
};

subtest validate_rich_menu_object => sub {
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
        my $res = $bot->validate_rich_menu_object( $rich_menu );
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/bot/richmenu/validate';

        return +{};
    };
};

done_testing;
