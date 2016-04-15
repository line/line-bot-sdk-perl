use strict;
use warnings;
use Test::More;
use t::Util;

use LINE::Bot::API::Receive;

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


subtest 'signature_validation' => sub {
    subtest 'failed' => sub {
        ok(! LINE::Bot::API::Receive->signature_validation($json, $config->{channel_secret}, ''));
    };

    subtest 'successful' => sub {
        ok(LINE::Bot::API::Receive->signature_validation($json, $config->{channel_secret}, 'YdUyzEMBcQwsneRE8RkWm9/3AF+Zms+Mj1sh7d/biuc'));
    };
};

subtest 'from_json' => sub {
    my $requests = LINE::Bot::API::Receive->new_from_json($config, $json);

    is scalar(@{ $requests }), 2;

    subtest 'message' => sub {
        my $req = $requests->[0];
        isa_ok $req, 'LINE::Bot::API::Receive::Message::Text';
        ok $req->is_message;
        ok !$req->is_operation;
        ok $req->is_valid_event;
        ok $req->is_sent_me;

        is $req->id, 'ABCDEF-12345678901';
        is $req->content_id, '325708';
        is $req->created_time, '1332394961610';
        is $req->from_mid, 'uff2aec188e58752ee1fb0f9507c6529a';

        ok $req->is_text;
        ok $req->text, 'hello';
    };

    subtest 'operation' => sub {
        my $req = $requests->[1];
        isa_ok $req, 'LINE::Bot::API::Receive::Operation::AddContact';
        ok !$req->is_message;
        ok $req->is_operation;
        ok $req->is_valid_event;

        ok $req->is_add_contact;
        is $req->revision, '2469';
        is $req->from_mid, 'u0f3bfc598b061eba02183bfc5280886a';
    };

};

done_testing;
