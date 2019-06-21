# NAME

LINE::Bot::API - SDK of the LINE Messaging API for Perl

<div>
    <a href="https://travis-ci.org/line/line-bot-sdk-perl"><img src="https://travis-ci.org/line/line-bot-sdk-perl.svg?branch=master"></a>
</div>

# SYNOPSIS

    # in the synopsis.psgi
    use strict;
    use warnings;
    use LINE::Bot::API;
    use LINE::Bot::API::Builder::SendMessage;
    use Plack::Request;

    my $bot = LINE::Bot::API->new(
        channel_secret       => $channel_secret,
        channel_access_token => $channel_access_token,
    );

    sub {
        my $req = Plack::Request->new(shift);

        unless ($req->method eq 'POST' && $req->path eq '/callback') {
            return [200, [], ['Not Found']];
        }

        unless ($bot->validate_signature($req->content, $req->header('X-Line-Signature'))) {
            return [200, [], ['failed to validate signature']];
        }

        my $events = $bot->parse_events_from_json($req->content);
        for my $event (@{ $events }) {
            next unless $event->is_message_event && $event->is_text_message;

            my $messages = LINE::Bot::API::Builder::SendMessage->new;
            $messages->add_text( text => $event->text );
            $bot->reply_message($event->reply_token, $messages->build);
        }

        return [200, [], ["OK"]];
    };

# DESCRIPTION

LINE::Bot::API is a client library which lets you easily start using the LINE Messaging API.
You can create a bot which runs on the LINE app by registering for a LINE Messaging API account.
You can create a **Messaging API** account from the [LINE Business Center](https://business.line.me/).

You can find the **Channel secret** and **Channel access token** on the Basic information page on the Channel Console which you can access from the [LINE Business Center](https://business.line.me/).

Use this documentation and the LINE Developers documentation to get you started developing your own bot!

# METHODS

## new(%args)

Create a new LINE::Bot::API instance.

     my $bot = LINE::Bot::API->new(
        channel_secret       => $channel_secret,
        channel_access_token => $channel_access_token,
    );

## reply\_message($reply\_token, \[ $message, ... \] )

Send reply messages to a user, room or group.

    my $messages = LINE::Bot::API::Builder::SendMessage->new;
    $messages->add_text( text => 'Example reply text' );

    my $ret = $bot->reply_message($reply_token, $messages->build);
    unless ($ret->is_success) {
        # error
        warn $ret->message;
        for my $detail (@{ $ret->details // []}) {
            warn "    detail: " . $detail->{message};
        }
    }

You can get a `reply_token` from a [webhook event object](https://developers.line.biz/en/reference/messaging-api/#webhook-event-objects).
See the documentation for the `parse_events_from_json($json)` method.

See also the API reference of this method: [https://developers.line.biz/en/reference/messaging-api/#send-reply-message](https://developers.line.biz/en/reference/messaging-api/#send-reply-message)

## push\_message($user\_id|$room\_id|$group\_id, \[ $message, ... \])

Send push messages to a user, room or group.

    my $messages = LINE::Bot::API::Builder::SendMessage->new;
    $messages->add_text( text => 'Example push text' );
    $bot->push_message($user_id, $messages->build);

You can get a `user_id`, `room_id` or `group_id` from a [webhook event object](https://developers.line.biz/en/reference/messaging-api/#webhook-event-objects)
See the documentation for the `parse_events_from_json($json)` method.

See also the LINE Developers API reference of this method: [https://developers.line.biz/en/reference/messaging-api/#send-push-message](https://developers.line.biz/en/reference/messaging-api/#send-push-message)

## multicast(\[$user\_id, ... \], \[ $message, ... \])

Send push messages to multiple users.

    my $messages = LINE::Bot::API::Builder::SendMessage->new;
    $messages->add_text( text => 'Example push text' );
    $bot->multicast([ $user_id ], $messages->build);

You can get a `user_id` from a [webhook event object](https://developers.line.biz/en/reference/messaging-api/#webhook-event-objects).
See the documentation for the `parse_events_from_json($json)` method.

See also the LINE Developers API reference of this method: [https://developers.line.biz/en/reference/messaging-api/#send-multicast-messages](https://developers.line.biz/en/reference/messaging-api/#send-multicast-messages)

## broadcast(\[ $message, ... \])

Sends push messages to multiple users at any time.

    my $messages = LINE::Bot::API::Builder::SendMessage->new;
    $messages->add_text( text => 'Example push text' );
    $bot->broadcast($messages->build);

See also the LINE Developers API reference of this method: [https://developers.line.biz/en/reference/messaging-api/#send-broadcast-message](https://developers.line.biz/en/reference/messaging-api/#send-broadcast-message)

## validate\_signature($json, $signature)

    my $req = Plack::Request->new( ... );
    unless ($bot->validate_signature($req->content, $req->header('X-Line-Signature'))) {
        die 'failed to signature validation';
    }

## parse\_events\_from\_json($json)

Parse webhook event objects and build [LINE::Bot::API::Event](https://metacpan.org/pod/LINE::Bot::API::Event) instances.

    my $req = Plack::Request->new( ... );
    my $events = $bot->parse_events_from_json($req->content);
    for my $event (@{ $events }) {
        unless ($event->is_unfollow_event && $event->is_leave_event) {
            # Get a reply_token
            my $reply_token = $event->reply_token;
        }
        if ($event->is_user_event) {
            # Get a user_id
            my $user_id = $event->user_id;
        }
        if ($event->is_room_event) {
            # Get a room_id
            my $room_id = $event->room_id;
        }
        if ($event->is_group_event) {
            # Get a group_id
            my $group_id = $event->group_id;
        }

        if ($event->is_message_event) {
            # Get a message id
            my $message_id = $event->message_id;
        }
    }

## leave\_room($room\_id)

Bot leaves a room.

    $bot->leave_room($room_id);

You can get a `room_id` by a [Webhook Event Object](https://developers.line.biz/en/reference/messaging-api/#webhook-event-objects).
And see also `parse_events_from_json($json)` method's document.

## leave\_group($group\_id)

Bot leaves a group.

    $bot->leave_group($group_id);

You can get a `group_id` from a [webhook event object](https://developers.line.biz/en/reference/messaging-api/#webhook-event-objects).
See the documentation for the `parse_events_from_json($json)` method.

## get\_message\_content($message\_id)

Get the original file which was sent by user.

    my $ret = $bot->get_message_content($message_id);
    if ($ret->is_success) {
        my $filename = $ret->fh->filename;
        open my $fh, '<', $file or die "$!: $file";
        ...
    }

You can get a `message_id` from a [webhook event object](https://developers.line.biz/en/reference/messaging-api/#webhook-event-objects).
See the documentation for the `parse_events_from_json($json)` method.

You can also see the online API reference documentation.

See also the LINE Developers API reference of this method: [https://developers.line.biz/en/reference/messaging-api/#get-content](https://developers.line.biz/en/reference/messaging-api/#get-content)

## get\_target\_limit\_for\_additional\_messages

Gets the target limit for additional messages in the current month.

See also the LINE Developers API reference of this method:  [https://developers.line.biz/en/reference/messaging-api/#get-quota](https://developers.line.biz/en/reference/messaging-api/#get-quota)

## get\_number\_of\_messages\_sent\_this\_month

Gets the number of messages sent in the current month.

See also the LINE Developers API reference of this method:  [https://developers.line.biz/en/reference/messaging-api/#get-consumption](https://developers.line.biz/en/reference/messaging-api/#get-consumption)

## get\_profile($user\_id)

Get user profile information.

    my $ret = $bot->get_profile($user_id);
    if ($ret->is_success) {
        say $ret->display_name;
        say $ret->user_id;
        say $ret->picture_url;
        say $ret->status_message;
    }

See also the LINE Developers API reference of this method:  [https://developers.line.biz/en/reference/messaging-api/#get-profile](https://developers.line.biz/en/reference/messaging-api/#get-profile)

## `get_number_of_sent_reply_messages($date)`

Gets the number of messages sent with the `/bot/message/reply` endpoint.

The number of messages retrieved by this operation does not include
the number of messages sent from LINE@ Manager.

The `$date` parameter is "yyyyMMdd" format.

## `get_number_of_sent_push_messages($date)`

Gets the number of messages sent with the `/bot/message/push` endpoint.

The number of messages retrieved by this operation does not include the number of messages sent from LINE@ Manager.

- date

    Date the messages were sent

        Format: yyyyMMdd (Example: 20191231)
        Timezone: UTC+9

## `get_number_of_sent_multicast_messages($date)`

Gets the number of messages sent with the `/bot/message/multicast` endpoint.

The number of messages retrieved by this operation does not include the number of messages sent from LINE@ Manager.

- date

    Date the messages were sent

        Format: yyyyMMdd (Example: 20191231)
        Timezone: UTC+9

## `get_number_of_send_broadcast_messages($date)`

Gets the number of messages sent with the `/bot/message/broadcast` endpoint.

The number of messages retrieved by this operation does not include the number of messages sent from LINE Official Account Manager.

- date

    Date the messages were sent

        Format: yyyyMMdd (Example: 20191231)
        Timezone: UTC+9

## `create_rich_menu( $rich_menu_object )`

This method corresponds to the API of [Creating rich menu](https://developers.line.biz/en/reference/messaging-api/#create-rich-menu)

One argument is needed: `$rich_menu_object`, which is a plain HashRef representing [rich menu object](https://developers.line.biz/en/reference/messaging-api/#rich-menu-object)

## `get_rich_menu( $rich_menu_id )`

This method corresponds to the API of [Get rich menu](https://developers.line.biz/en/reference/messaging-api/#get-rich-menu)

One argument is needed: $rich\_menu\_id -- which correspond to the
richMenuId property of the object returned by `create_rich_menu`
method.

## `delete_rich_menu( $rich_menu_id )`

This method corresponds to the API of [Delete rich menu](https://developers.line.biz/en/reference/messaging-api/#delete-rich-menu)

One argument is needed: $rich\_menu\_id -- which correspond to the
richMenuId property of the object returned by `create_rich_menu`
method.

The return value is an empty RichMenu object -- only status code
matters. Upon successful deletion, status code 200 is returned.

## `get_rich_menu_list`

This method corresponds to the API of [Get rich menu list](https://developers.line.biz/en/reference/messaging-api/#get-rich-menu-list)

No arguments are needed.

## `set_default_rich_menu( $rich_menu_id )`

This method corresponds to the API of [Set default rich menu](https://developers.line.biz/en/reference/messaging-api/#set-default-rich-menu)

One argument is needed: $rich\_menu\_id -- which correspond to the
richMenuId property of the object returned by `create_rich_menu`
method.

## `get_default_rich_menu_id`

This method corresponds to the API of [Get default rich menu ID](https://developers.line.biz/en/reference/messaging-api/#get-default-rich-menu-id)

No arguments are needed. The return value is a RichMenu object with only one property: richMenuId.

## `cancel_default_rich_menu`

This method corresponds to the API of [Cancel default rich menu ID](https://developers.line.biz/en/reference/messaging-api/#cancel-default-rich-menu)

## `link_rich_menu_to_user( $user_id, $rich_menu_id )`

This method corresponds to the API of [Link rich menu to user](https://developers.line.biz/en/reference/messaging-api/#link-rich-menu-to-user)

Both of `$user_id` and `$rich_menu_id` are required.

## `link_rich_menu_to_multiple_users( $user_ids, $rich_menu_id )`

This method corresponds to the API of [Link rich menu to multiple users](https://developers.line.biz/en/reference/messaging-api/#link-rich-menu-to-users)

Both of `$user_ids` and `$rich_menu_id` are required. `$user_ids`
should be an ArrayRef of user ids, while `$rich_menu_id` should be a
simple scalar.

## `get_rich_menu_id_of_user( $user_id )`

This method corresponds to the API of [Get rich menu ID of user](https://developers.line.biz/en/reference/messaging-api/#get-rich-menu-id-of-user)

The argument `$user_id` is mandatory.  The return value is a RichMenu
object with only one property: richMenuId.

## `unlink_rich_menu_from_user( $user_id )`

This method corresponds to the API of [Unlink rich menu from user](https://developers.line.biz/en/reference/messaging-api/#unlink-rich-menu-from-user)

The argument `$user_id` is mandatory. The return value is an empty object.

## `unlink_rich_menu_from_multiple_users( $user_ids )`

This method corresponds to the API of [Unlink rich menu from multiple users](https://developers.line.biz/en/reference/messaging-api/#unlink-rich-menu-from-users)

The mandatory argument `$user_ids` is an ArrayRef of user ids. The return value is an empty object.

## How to build a send message object

See the LINE Developers API reference about [Message objects](https://developers.line.biz/en/reference/messaging-api/#message-objects)

When the `LINE::Bot::API::Builder::SendMessage` class is used, it is possible easily to build a send message object.
That class supports a fluent interface.

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_text(
        text => 'Closing the distance',
    )->add_image(
        image_url   => 'http://example.com/image.jpg',
        preview_url => 'http://example.com/image_preview.jpg',
    );
    $bot->reply_message($reply_token, $messages->build);

### Text type

Build a text type object.

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_text(
        text => 'Closing the distance',
    );
    $bot->reply_message($reply_token, $messages->build);

### Image type

Build an image type object.

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_image(
        image_url   => 'http://example.com/image.jpg',
        preview_url => 'http://example.com/image_preview.jpg',
    );
    $bot->reply_message($reply_token, $messages->build);

### Video type

Build a video type object.

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_video(
        video_url   => 'http://example.com/video.mp4',
        preview_url => 'http://example.com/video_preview.jpg',
    );
    $bot->reply_message($reply_token, $messages->build);

### Audio type

Build an audio type object.

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_audio(
        audio_url => 'http://example.com/image.m4a',
        duration  => 3601_000, # msec
    );
    $bot->reply_message($reply_token, $messages->build);

### Location type

Build a location type object.

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_location(
        title     => 'LINE Corporation.',
        address   => 'Hikarie  Shibuya-ku Tokyo 151-0002',
        latitude  => 35.6591,
        longitude => 139.7040,
    );
    $bot->reply_message($reply_token, $messages->build);

### Sticker type

Build a sticker type object.

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_sticker(
        package_id => '1',
        sticker_id => '2',
    );
    $bot->reply_message($reply_token, $messages->build);

### Imagemap type

To build a message of imagemap type, you may use a helper module.

    my $imagemap = LINE::Bot::API::Builder::ImagemapMessage->new(
        base_url    => 'https://example.com/bot/images/rm001',
        alt_text    => 'this is an imagemap',
        base_width  => 1040,
        base_height => 1040,
    )->add_uri_action(
        uri         => 'http://example.com/',
        area_x      => 0,
        area_y      => 0,
        area_width  => 1040,
        area_height => 520,
    )->add_message_action(
        text        => 'message',
        area_x      => 0,
        area_y      => 520,
        area_width  => 1040,
        area_height => 520,
    );

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_imagemap($imagemap->build);
    $bot->reply_message($reply_token, $messages->build);

An Imagemap message can contain a video area inside. Here is an example of one withe upper half being a video overlay:

    my $imagemap_message = LINE::Bot::API::Builder::ImagemapMessage->new(
        base_url    => 'https://example.com/bot/images/rm001',
        alt_text    => 'this is an imagemap',
        base_width  => 1040,
        base_height => 1040,
        video => {
            originalContentUrl => "https://example.com/video.mp4",
            previewImageUrl => "https://example.com/video_preview.jpg",
            area => {
                x => 0,
                y => 0,
                width => 1040,
                height => 585
            }
        }
    )->build;

For more detail about Imagemap message, see: [https://developers.line.biz/en/reference/messaging-api/#imagemap-message](https://developers.line.biz/en/reference/messaging-api/#imagemap-message)

### Template type

Build a template type object.
You can use a helper module for the template type.

#### Buttons type

    my $buttons = LINE::Bot::API::Builder::TemplateMessage->new_buttons(
        alt_text  => 'this is a buttons template',
        image_url => 'https://example.com/bot/images/image.jpg',
        title     => 'buttons',
        text      => 'description',
    )->add_postback_action(
        label => 'postback',
        data  => 'postback data',
        text  => 'postback message',
    )->add_message_action(
        label => 'message',
        text  => 'message',
    )->add_uri_action(
        label => 'uri',
        uri   => 'http://example.com/',
    )->add_message_action(
        label => 'message2',
        text  => 'message2',
    );

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_template($buttons->build);
    $bot->reply_message($reply_token, $messages->build);

#### Confirm type

    my $confirm = LINE::Bot::API::Builder::TemplateMessage->new_confirm(
        alt_text => 'this is a confirm template',
        text     => 'confirm',
    )->add_postback_action(
        label => 'postback',
        data  => 'postback data',
        text  => 'postback message',
    )->add_message_action(
        label => 'message',
        text  => 'message',
    )->add_uri_action(
        label => 'uri',
        uri   => 'http://example.com/',
    );

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_template($confirm->build);
    $bot->reply_message($reply_token, $messages->build);

#### Carousel type

    my $carousel = LINE::Bot::API::Builder::TemplateMessage->new_carousel(
        alt_text => 'this is a carousel template',
    );
    for my $i (1..5) {
        my $column = LINE::Bot::API::Builder::TemplateMessage::Column->new(
            image_url => 'https://example.com/bot/images/item.jpg',
            title     => "carousel $i",
            text      => "description $i",
        )->add_postback_action(
            label => 'postback',
            data  => 'postback data',
            text  => 'postback message',
        )->add_message_action(
            label => 'message',
            text  => 'message',
        )->add_uri_action(
            label => 'uri',
            uri   => 'http://example.com/',
        );
        $carousel->add_column($column->build);
    }

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_template($carousel->build);
    $bot->reply_message($reply_token, $messages->build);

#### Image Carousel type

    my $carousel = LINE::Bot::API::Builder::TemplateMessage->new_image_carousel(
        alt_text => 'this is a image carousel template',
    );

    my $column1 = LINE::Bot::API::Builder::TemplateMessage::ImageColumn->new(
        image_url => 'https://example.com/bot/images/item1.jpg',
    )->add_postback_action(
        label => 'postback',
        data  => 'postback data',
        text  => 'postback message',
    );
    $carousel->add_column($column1->build);

    my $column2 = LINE::Bot::API::Builder::TemplateMessage::ImageColumn->new(
        image_url => 'https://example.com/bot/images/item2.jpg',
    )->add_message_action(
        label => 'message',
        text  => 'message',
    );
    $carousel->add_column($column2->build);

    my $column3 = LINE::Bot::API::Builder::TemplateMessage::ImageColumn->new(
        image_url => 'https://example.com/bot/images/item3.jpg',
    )->add_uri_action(
        label => 'uri',
        uri   => 'http://example.com/',
    );
    $carousel->add_column($column3->build);

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_template($carousel->build);
    $bot->reply_message($reply_token, $messages->build);

# COPYRIGHT & LICENSE

Copyright 2016-2019 LINE Corporation

This Software Development Kit is licensed under The Artistic License 2.0.
You may obtain a copy of the License at
https://opensource.org/licenses/Artistic-2.0

# SEE ALSO

[LINE::Bot::API::Event](https://metacpan.org/pod/LINE::Bot::API::Event),
[https://developers.line.biz/](https://developers.line.biz/),
[https://at.line.me/](https://at.line.me/)
