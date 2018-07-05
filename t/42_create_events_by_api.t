use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::API;

my $config = +{
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
};

my $json = <<JSON;
{
 "events":[
  {
   "type":"message",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   },
   "replyToken":"replytoken",
   "message":{
    "id":"contentid",
    "type":"text",
    "text":"message"
   }
  },
  {
   "type":"message",
   "timestamp":12345678901234,
   "source":{
    "type":"group",
    "groupId":"groupid"
   },
   "replyToken":"replytoken",
   "message":{
    "id":"contentid",
    "type":"image"
   }
  },
  {
   "type":"message",
   "timestamp":12345678901234,
   "source":{
    "type":"room",
    "roomId":"roomid"
   },
   "replyToken":"replytoken",
   "message":{
    "id":"contentid",
    "type":"video"
   }
  },
  {
   "type":"message",
   "timestamp":12345678901234,
   "source":{
    "type":"room",
    "roomId":"roomid"
   },
   "replyToken":"replytoken",
   "message":{
    "id":"contentid",
    "type":"audio"
   }
  },
  {
   "type":"message",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   },
   "replyToken":"replytoken",
   "message":{
    "id":"contentid",
    "type":"location",
    "title":"label",
    "address":"tokyo",
    "latitude":-34.12,
    "longitude":134.23
   }
  },
  {
   "type":"message",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   },
   "replyToken":"replytoken",
   "message":{
    "id":"contentid",
    "type":"sticker",
    "packageId":"1",
    "stickerId":"2"
   }
  },
  {
   "type":"follow",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   },
   "replyToken":"replytoken"
  },
  {
   "type":"unfollow",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   }
  },
  {
   "type":"join",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   },
   "replyToken":"replytoken"
  },
  {
   "type":"leave",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   }
  },
  {
   "type":"postback",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   },
   "replyToken":"replytoken",
   "postback.data":"postback"
  },
  {
   "type":"beacon",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   },
   "replyToken":"replytoken",
   "beacon.hwid":"bid",
   "beacon.type":"enter"
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
        ok($bot->validate_signature($json, 'QHWgy4GThTN7vK1Nh7fRzNVCAIptZuEFm4V1x6mQFp4='));
    };
};

subtest 'parse_events_from_json' => sub {
    my $events = $bot->parse_events_from_json($json);
    is scalar(@{ $events }), 12;
};

done_testing;
