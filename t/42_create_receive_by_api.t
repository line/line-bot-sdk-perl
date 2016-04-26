use strict;
use warnings;
use Test::More;
use t::Util;

use LINE::Bot::API;

my $config = +{
    channel_id     => 1441301333,
    channel_secret => 'testsecret',
    channel_mid    => 'u0a556cffd4da0dd89c94fb36e36e1cdc',

};

my $json = <<JSON;
{
  "result":[
    {
      "from":"u206d25c2ea6bd87c17655609a1c37cb8",
      "fromChannel":"1341301815",
      "to":["u0cc15697597f61dd8b01cea8b027050e"],
      "toChannel":"1441301333",
      "eventType":"138311609000106303",
      "id":"ABCDEF-12345678901",
      "content":{
        "id":"325708",
        "createdTime":1332394961610,
        "from":"uff2aec188e58752ee1fb0f9507c6529a",
        "to":["u0a556cffd4da0dd89c94fb36e36e1cdc"],
        "toType":1,
        "contentType":1,
        "text":"hello"
      }
    },
    {
      "from":"u206d25c2ea6bd87c17655609a1c37cb8",
      "fromChannel":"1341301815",
      "to":["u0cc15697597f61dd8b01cea8b027050e"],
      "toChannel":"1441301333",
      "eventType":"138311609100106403",
      "id":"ABCDEF-12345678902",
      "content":{
        "revision":2469,
        "opType":4,
        "params":[
          "u0f3bfc598b061eba02183bfc5280886a",
          null,
          null
        ]
      }
    }
  ]
}
JSON

my $bot = LINE::Bot::API->new(%{ $config });


subtest 'validate_signature' => sub {
    subtest 'failed' => sub {
        ok(! $bot->validate_signature($json, ''));
    };

    subtest 'successful' => sub {
        ok($bot->validate_signature($json, 'YdUyzEMBcQwsneRE8RkWm9/3AF+Zms+Mj1sh7d/biuc'));
    };
};

subtest 'from_json' => sub {

    my $receives = $bot->create_receives_from_json($json);

    is scalar(@{ $receives }), 2;

    my $receive = $receives->[0];
    isa_ok $receive, 'LINE::Bot::API::Receive::Message::Text';
    ok $receive->is_message;
    ok $receive->is_text;
    ok $receive->text, 'hello';
};

done_testing;
