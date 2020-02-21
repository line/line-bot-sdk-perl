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
   "mode":"active",
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
   "mode":"active",
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
   "mode":"active",
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
   "mode":"active",
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
   "mode":"active",
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
   "mode":"active",
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
   "mode":"active",
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
   "mode":"active",
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
   "mode":"active",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   },
   "replyToken":"replytoken"
  },
  {
   "type":"unfollow",
   "mode":"active",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   }
  },
  {
   "type":"join",
   "mode":"active",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   },
   "replyToken":"replytoken"
  },
  {
   "type":"leave",
   "mode":"active",
   "timestamp":12345678901234,
   "source":{
    "type":"user",
    "userId":"userid"
   }
  },
  {
   "type":"postback",
   "mode":"active",
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
   "mode":"active",
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
   "mode":"active",
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
  },
  {
   "type":"memberJoined",
   "mode":"active",
   "timestamp":12345678901234,
   "source":{
    "type":"group",
    "groupId":"groupid"
   },
   "replyToken":"replytoken"
  },
  {
   "type":"memberLeft",
   "mode":"active",
   "timestamp":12345678901234,
   "source":{
    "type":"group",
    "groupId":"groupid"
   }
  },
  {
    "type": "things",
    "replyToken": "replytoken",
    "timestamp": 12345678901234,
    "source": {
      "type": "user",
      "userId": "userid"
    },
    "things": {
      "deviceId": "deviceid",
      "type": "link"
    }
  },
  {
    "type": "things",
    "replyToken": "replytoken",
    "timestamp": 12345678901234,
    "source": {
      "type": "user",
      "userId": "userid"
    },
    "things": {
      "deviceId": "deviceid",
      "type": "unlink"
    }
  },
  {
    "type": "accountLink",
    "replyToken": "replytoken",
    "timestamp": 12345678901234,
    "source": {
      "userId": "U91eeaf62d...",
      "type": "user"
    },
    "link": {
      "result": "ok",
      "nonce": "xxxxxxxxxxxxxxx"
    }
  },
  {
    "replyToken": "nHuyWiB7yP5Zw52FIkcQobQuGDXCTA",
    "type": "message",
    "mode": "active",
    "timestamp": 1462629479859,
    "source": {
      "type": "user",
      "userId": "U4af4980629..."
    },
    "message": {
      "id": "325708",
      "type": "video",
      "duration": 60000,
      "contentProvider": {
        "type": "external",
        "originalContentUrl": "https://example.com/original.mp4",
        "previewImageUrl": "https://example.com/preview.jpg"
      }
    }
  },
  {
    "type": "message",
    "mode": "active",
    "timestamp": 1462629479859,
    "source": {
      "type": "user",
      "userId": "xxxxxxxxx"
    },
    "message": {
      "id": "325708",
      "type": "image",
      "contentProvider": {
        "type": "external",
        "originalContentUrl": "https://example.com/original.jpg",
        "previewImageUrl": "https://example.com/preview.jpg"
      }
    }
  },
  {
    "type": "message",
    "mode": "active",
    "timestamp": 1462629479859,
    "source": {
      "type": "user",
      "userId": "xxxxxxxxx"
    },
    "message": {
      "id": "325708",
      "type": "audio",
      "duration": 60000,
      "contentProvider": {
        "type": "external",
        "originalContentUrl": "https://example.com/original.mp3"
      }
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
        ok(LINE::Bot::API::Event->validate_signature($json, $config->{channel_secret}, 's9XZ23g7U1vOL7WESam0DY/IRu4LkIxPSezfkPEq1R0='));
    };
};

subtest 'parse_events_json' => sub {
    my $events = LINE::Bot::API::Event->parse_events_json($json);

    is scalar(@{ $events }), 23;

    subtest 'message' => sub {
        subtest 'text' => sub {
            my $event = $events->[0];
            is $event->message_type, 'text';
            is $event->mode, 'active';
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
            is $event->mode, 'active';
            ok $event->is_group_event;
            is $event->group_id, 'groupid';
            is $event->user_id, 'userid';
        };
        subtest 'text room' => sub {
            my $event = $events->[2];
            is $event->mode, 'active';
            ok $event->is_room_event;
            is $event->room_id, 'roomid';
            is $event->user_id, 'userid';
        };
        subtest 'image (without contentProvider)' => sub {
            my $event = $events->[3];
            is $event->mode, 'active';
            is $event->message_type, 'image';
            ok $event->is_group_event;
            is $event->group_id, 'groupid';
            ok $event->is_image_message;
            is $event->reply_token, 'replytoken';
            ok ! $event->content_provider;
        };
        subtest 'video without contentProvider' => sub {
            my $event = $events->[4];
            is $event->mode, 'active';
            is $event->message_type, 'video';
            ok $event->is_room_event;
            is $event->room_id, 'roomid';
            ok $event->is_video_message;
            is $event->reply_token, 'replytoken';

            ok ! $event->content_provider;
        };
        subtest 'audio without contentProvider' => sub {
            my $event = $events->[5];
            is $event->mode, 'active';
            is $event->message_type, 'audio';
            ok $event->is_audio_message;
            is $event->reply_token, 'replytoken';

            ok ! $event->content_provider;
        };
        subtest 'location' => sub {
            my $event = $events->[6];
            is $event->mode, 'active';
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
            is $event->mode, 'active';
            is $event->message_type, 'sticker';
            ok $event->is_sticker_message;
            is $event->reply_token, 'replytoken';
            is $event->package_id, '1';
            is $event->sticker_id, '2';
        };
    };

    subtest 'follow' => sub {
        my $event = $events->[8];
        is $event->mode, 'active';
        ok $event->is_follow_event;
        is $event->reply_token, 'replytoken';
    };

    subtest 'unfollow' => sub {
        my $event = $events->[9];
        is $event->mode, 'active';
        ok $event->is_unfollow_event;
        is $event->reply_token, undef;
    };

    subtest 'join' => sub {
        my $event = $events->[10];
        is $event->mode, 'active';
        ok $event->is_join_event;
        is $event->reply_token, 'replytoken';
    };

    subtest 'leave' => sub {
        my $event = $events->[11];
        is $event->mode, 'active';
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

    subtest 'memberJoined' => sub {
        my $event = $events->[15];
        ok $event->is_member_join_event;
        is $event->reply_token, 'replytoken';
    };

    subtest 'memberLeft' => sub {
        my $event = $events->[16];
        ok $event->is_member_leave_event;
        is $event->reply_token, undef;
    };

    subtest 'things' => sub {
        subtest 'link' => sub {
            my $event = $events->[17];
            ok $event->is_things_event;
            ok $event->is_device_link;
            is $event->reply_token, 'replytoken';
            is $event->things_device_id, 'deviceid';
            is $event->things_type, 'link';
        };
        subtest 'unlink' => sub {
            my $event = $events->[18];
            ok $event->is_things_event;
            ok $event->is_device_unlink;
            is $event->reply_token, 'replytoken';
            is $event->things_device_id, 'deviceid';
            is $event->things_type, 'unlink';
        };
    };

    subtest 'accountLink' => sub {
        my $event = $events->[19];
        is ref($event->link), ref({});
        is $event->link->{result}, "ok";
        is $event->link->{nonce}, "xxxxxxxxxxxxxxx";
        is((0+ keys %{$event->link}), 2);
        is $event->type, "accountLink";
        ok defined($event->replyToken);
        ok defined($event->timestamp);
        ok defined($event->source);
    };

    subtest 'video with contentProvider' => sub {
        my $event = $events->[20];

        is $event->mode, 'active';
        is $event->message_type, 'video';
        ok $event->content_provider;

        is_deeply $event->content_provider, {
            "type" => "external",
            "originalContentUrl" => "https://example.com/original.mp4",
            "previewImageUrl" => "https://example.com/preview.jpg"
        };
    };

    subtest 'image with contentProvider' => sub {
        my $event = $events->[21];

        is $event->mode, 'active';
        is $event->message_type, 'image';
        ok $event->content_provider;
        is_deeply $event->content_provider, {
            "type" => "external",
            "originalContentUrl" => "https://example.com/original.jpg",
            "previewImageUrl" => "https://example.com/preview.jpg"
        };
    };

    subtest 'audio with contentProvider' => sub {
        my $event = $events->[22];

        is $event->mode, 'active';
        is $event->message_type, 'audio';
        ok $event->content_provider;
        is_deeply $event->content_provider, {
            "type" => "external",
            "originalContentUrl" => "https://example.com/original.mp3"
        };
    };
};

done_testing;
