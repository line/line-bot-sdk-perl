use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::API::Event;

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
    "groupId":"groupid",
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
    "type":"room",
    "roomId":"roomid",
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
   "postback":{
    "data":"postback"
   }
  },
  {
   "type":"beacon",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   },
   "replyToken":"replytoken",
   "beacon":{
    "hwid":"bid",
    "type":"enter",
    "dm":"1234567890abcdef"
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
    "type":"file",
    "fileName": "file.txt",
    "fileSize": 2138
   }
  }
 ]
}
JSON


subtest 'validate_signature' => sub {
    subtest 'failed' => sub {
        ok(! LINE::Bot::API::Event->validate_signature($json, $config->{channel_secret}, ''));
    };

    subtest 'successful' => sub {
        ok(LINE::Bot::API::Event->validate_signature($json, $config->{channel_secret}, 'tfZMGk9LcFNAE5NUdUBaDuDzdGy3wmAOm8SjATX+Kc8='));
    };
};

subtest 'parse_events_json' => sub {
    my $events = LINE::Bot::API::Event->parse_events_json($json);

    is scalar(@{ $events }), 15;

    subtest 'message' => sub {
        subtest 'text' => sub {
            my $event = $events->[0];
            is $event->message_type, 'text';
            is $event->timestamp, 12345678901234;
            ok $event->is_user_event;
            is $event->user_id, 'userid';
            ok $event->is_message_event;
            ok $event->is_text_message;
            is $event->reply_token, 'replytoken';
            is $event->message_id, 'contentid';
            is $event->text, 'message';
        };
        subtest 'text group' => sub {
            my $event = $events->[1];
            ok $event->is_group_event;
            is $event->group_id, 'groupid';
            is $event->user_id, 'userid';
        };
        subtest 'text room' => sub {
            my $event = $events->[2];
            ok $event->is_room_event;
            is $event->room_id, 'roomid';
            is $event->user_id, 'userid';
        };
        subtest 'image' => sub {
            my $event = $events->[3];
            is $event->message_type, 'image';
            ok $event->is_group_event;
            is $event->group_id, 'groupid';
            ok $event->is_image_message;
            is $event->reply_token, 'replytoken';
        };
        subtest 'video' => sub {
            my $event = $events->[4];
            is $event->message_type, 'video';
            ok $event->is_room_event;
            is $event->room_id, 'roomid';
            ok $event->is_video_message;
            is $event->reply_token, 'replytoken';
        };
        subtest 'audio' => sub {
            my $event = $events->[5];
            is $event->message_type, 'audio';
            ok $event->is_audio_message;
            is $event->reply_token, 'replytoken';
        };
        subtest 'location' => sub {
            my $event = $events->[6];
            is $event->message_type, 'location';
            ok $event->is_location_message;
            is $event->reply_token, 'replytoken';
            is $event->title, 'label';
            is $event->address, 'tokyo';
            is $event->latitude, -34.12;
            is $event->longitude, 134.23;
        };
        subtest 'sticker' => sub {
            my $event = $events->[7];
            is $event->message_type, 'sticker';
            ok $event->is_sticker_message;
            is $event->reply_token, 'replytoken';
            is $event->package_id, '1';
            is $event->sticker_id, '2';
        };
    };

    subtest 'follow' => sub {
        my $event = $events->[8];
        ok $event->is_follow_event;
        is $event->reply_token, 'replytoken';
    };

    subtest 'unfollow' => sub {
        my $event = $events->[9];
        ok $event->is_unfollow_event;
        is $event->reply_token, undef;
    };

    subtest 'join' => sub {
        my $event = $events->[10];
        ok $event->is_join_event;
        is $event->reply_token, 'replytoken';
    };

    subtest 'leave' => sub {
        my $event = $events->[11];
        ok $event->is_leave_event;
        is $event->reply_token, undef;
    };

    subtest 'postback' => sub {
        my $event = $events->[12];
        ok $event->is_postback_event;
        is $event->reply_token, 'replytoken';
        is $event->postback_data, 'postback';
    };

    subtest 'beacon' => sub {
        my $event = $events->[13];
        ok $event->is_beacon_detection_event;
        is $event->reply_token, 'replytoken';
        is $event->beacon_hwid, 'bid';
        is $event->beacon_type, 'enter';
        is $event->beacon_device_message, "\x12\x34\x56\x78\x90\xab\xcd\xef";
    };

    subtest 'file message' => sub {
        my $event = $events->[14];
        is $event->message_type, 'file';
        ok $event->is_file_message;
        is $event->reply_token, 'replytoken';
        is $event->file_size, 2138;
        is $event->file_name, 'file.txt';
    };
};

done_testing;
