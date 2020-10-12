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

## `new(%args)`

Create a new LINE::Bot::API instance.

     my $bot = LINE::Bot::API->new(
        channel_secret       => $channel_secret,
        channel_access_token => $channel_access_token,
    );

## `reply_message($reply_token, [ $message, ... ] )`

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

## `push_message( $user_id|$room_id|$group_id, $message, $options)`

Send push messages to a user, room or group.

    my $messages = LINE::Bot::API::Builder::SendMessage->new;
    $messages->add_text( text => 'Example push text' );
    $bot->push_message($user_id, $messages->build);

You can get a `user_id`, `room_id` or `group_id` from a [webhook event object](https://developers.line.biz/en/reference/messaging-api/#webhook-event-objects)
See the documentation for the `parse_events_from_json($json)` method.

The last parameter `$options` is an HashRef with a list of key-values
pairs to fine-tune the behaviour of this message. At the moment, the
only defined configurable option is `"retry_key"`, which requires an
UUID string for its value. See the section ["Handling Retries"](#handling-retries) for
the meaning of this particular option.

For mor detail, read the LINE Developers API reference of this method: [https://developers.line.biz/en/reference/messaging-api/#send-push-message](https://developers.line.biz/en/reference/messaging-api/#send-push-message)

## `multicast( $user_id, $message, $options )`

Send push messages to multiple users.

    my $messages = LINE::Bot::API::Builder::SendMessage->new;
    $messages->add_text( text => 'Example push text' );
    $bot->multicast([ $user_id ], $messages->build);

You can get a `user_id` from a [webhook event object](https://developers.line.biz/en/reference/messaging-api/#webhook-event-objects).
See the documentation for the `parse_events_from_json($json)` method.

The last parameter `$options` is an HashRef with a list of key-values
pairs to fine-tune the behaviour of this message. At the moment, the
only defined configurable option is `"retry_key"`, which requires an
UUID string for its value. See the section ["Handling Retries"](#handling-retries) for
the meaning of this particular option.

See also the LINE Developers API reference of this method: [https://developers.line.biz/en/reference/messaging-api/#send-multicast-messages](https://developers.line.biz/en/reference/messaging-api/#send-multicast-messages)

## `broadcast($message, $options)`

Sends push messages to multiple users at any time.

    my $messages = LINE::Bot::API::Builder::SendMessage->new;
    $messages->add_text( text => 'Example push text' );
    $bot->broadcast($messages->build);

The last parameter `$options` is an HashRef with a list of key-values
pairs to fine-tune the behaviour of this message. At the moment, the
only defined configurable option is `"retry_key"`, which requires an
UUID string for its value. See the section ["Handling Retries"](#handling-retries) for
the meaning of this particular option.

See also the LINE Developers API reference of thi smethod: [https://developers.line.biz/en/reference/messaging-api/#send-broadcast-message](https://developers.line.biz/en/reference/messaging-api/#send-broadcast-message)

## `validate_signature($json, $signature)`

    my $req = Plack::Request->new( ... );
    unless ($bot->validate_signature($req->content, $req->header('X-Line-Signature'))) {
        die 'failed to signature validation';
    }

## `parse_events_from_json($json)`

Parse webhook event objects and build [LINE::Bot::API::Event](https://metacpan.org/pod/LINE%3A%3ABot%3A%3AAPI%3A%3AEvent) instances.

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

## `leave_room($room_id)`

Bot leaves a room.

    $bot->leave_room($room_id);

You can get a `room_id` by a [Webhook Event Object](https://developers.line.biz/en/reference/messaging-api/#webhook-event-objects).
And see also `parse_events_from_json($json)` method's document.

## `leave_group($group_id)`

Bot leaves a group.

    $bot->leave_group($group_id);

You can get a `group_id` from a [webhook event object](https://developers.line.biz/en/reference/messaging-api/#webhook-event-objects).
See the documentation for the `parse_events_from_json($json)` method.

## `get_message_content($message_id)`

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

## `get_target_limit_for_additional_messages`

Gets the target limit for additional messages in the current month.

See also the LINE Developers API reference of this method:  [https://developers.line.biz/en/reference/messaging-api/#get-quota](https://developers.line.biz/en/reference/messaging-api/#get-quota)

## `get_number_of_messages_sent_this_month`

Gets the number of messages sent in the current month.

See also the LINE Developers API reference of this method:  [https://developers.line.biz/en/reference/messaging-api/#get-consumption](https://developers.line.biz/en/reference/messaging-api/#get-consumption)

## `get_number_of_message_deliveries({ date => ... })`

Get the number of messages sent from LINE official account on a specified day.

See also the LINE Developers API reference of this method: [https://developers.line.biz/en/reference/messaging-api/#get-number-of-delivery-messages](https://developers.line.biz/en/reference/messaging-api/#get-number-of-delivery-messages)

The argument is a HashRef with one pair of mandatory key-values;

    { date => "20191231" }

The formate of date is "yyyyMMdd", that is, year in 4 digits, month in
2 digits, and date-of-month in 2 digits.

The return value `$res` is a response object with the following read-only accessors
(see the API documentation for the meaning of each.)

    $res->status();     #=> Str
    $res->broadcast();  #=> Num
    $res->targeting();  #=> Num

Notice that the "status" does not mean HTTP status. To inspect actual
HTTP status, invoke `$res-`http\_status()>.

## `get_profile($user_id)`

Get user profile information.

    my $ret = $bot->get_profile($user_id);
    if ($ret->is_success) {
        say $ret->display_name;
        say $ret->user_id;
        say $ret->picture_url;
        say $ret->status_message;
        say $ret->language;
    }

See also the LINE Developers API reference of this method:  [https://developers.line.biz/en/reference/messaging-api/#get-profile](https://developers.line.biz/en/reference/messaging-api/#get-profile)

## `get_friend_demographics`

Retrieves the demographic attributes for a LINE Official Account's friends.

See also the LINE Developers API reference of this method: [https://developers.line.biz/en/reference/messaging-api/#get-demographic](https://developers.line.biz/en/reference/messaging-api/#get-demographic)

## `get_group_member_profile($group_id, $user_id)`

Get group user profile information.

    my $ret = $bot->get_group_member_profile($group_id, $user_id);
    if ($ret->is_success) {
        say $ret->display_name;
        say $ret->user_id;
        say $ret->picture_url;
    }

See also the LINE Developers API reference of this method:  [https://developers.line.biz/en/reference/messaging-api/#get-group-member-profile](https://developers.line.biz/en/reference/messaging-api/#get-group-member-profile)

## `get_member_in_room_count($room_id)`

Gets the count of members in a room. You can get the member in room count even if the user hasn't added the LINE Official Account as a friend or has blocked the LINE Official Account.

    my $ret = $bot->get_member_in_room_count($room_id);
    if ($ret->is_success) {
        say $ret->count;
    }

See also the LINE Developers API reference of this method:  [https://developers.line.biz/en/reference/messaging-api/#get-members-room-count](https://developers.line.biz/en/reference/messaging-api/#get-members-room-count)

## `get_member_in_group_count($group_id)`

Gets the count of members in a group. You can get the member in group count even if the user hasn't added the LINE Official Account as a friend or has blocked the LINE Official Account.

    my $ret = $bot->get_member_in_group_count($group_id);
    if ($ret->is_success) {
        say $ret->count;
    }

See also the LINE Developers API reference of this method:  [https://developers.line.biz/en/reference/messaging-api/#get-members-group-count](https://developers.line.biz/en/reference/messaging-api/#get-members-group-count)

## `get_group_summary($group_id)`

Gets the group ID, group name, and group icon URL of a group where the LINE Official Account is a member.

    my $ret = $bot->get_group_summary($group_id);
    if ($ret->is_success) {
        say $ret->group_id;
        say $ret->group_name;
        say $ret->picture_url;
    }

See also the LINE Developers API reference of this method:  [https://developers.line.biz/en/reference/messaging-api/#get-group-summary](https://developers.line.biz/en/reference/messaging-api/#get-group-summary)

## `get_room_member_profile($room_id, $user_id)`

Get room user profile information.
A room is like a group without a group name.
The response is similar to get\_group\_member\_profile.

See also the LINE Developers API reference of this method:  [https://developers.line.biz/en/reference/messaging-api/#get-room-member-profile](https://developers.line.biz/en/reference/messaging-api/#get-room-member-profile)

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

## `issue_channel_access_token({ client_id => '...', client_secret => '...' })`

This method corresponds to the API of: [Issue Channel access token](https://developers.line.biz/en/reference/messaging-api/#issue-channel-access-token)

The argument is a HashRef with two pairs of mandatory key-values:

    {
        client_id => "...",
        client_secret => "...",
    }

Both pieces of information can be accquired from the [channel console](https://metacpan.org/pod/client_id).

When a 200 OK HTTP response is returned, a new token is issued. In this case, you may want to store the values in "access\_token", "expires\_in", and "token\_type" attributes of the response object for future use.

Otherwise, you my examine the "error" attribute and "error\_description" attribute for more information about the error.

## `issue_channel_access_token_v2_1({ jwt => '...' })`

This method corresponds to the API of: [Issue Channel access token v2.1](https://developers.line.biz/en/reference/messaging-api/#issue-channel-access-token-v2-1)

The argument is a HashRef with a pair of mandatory key-values:

    {
        jwt => "...",
    }

This method lets you use JWT assertion for authentication.

When a 200 OK HTTP response is returned, a new token is issued. In this case, you may want to store the values in "access\_token", "expires\_in", "token\_type" and "key\_id" attributes of the response object for future use.

Otherwise, you may examine the "error" attribute and "error\_description" attribute for more information about the error.

## `get_valid_channel_access_token_v2_1({ jwt => '...' })`

This method corresponds to the API of: [Get all valid channel access token key IDs v2.1](https://developers.line.biz/en/reference/messaging-api/#get-all-valid-channel-access-token-key-ids-v2-1)

The argument is a HashRef with a pair of mandatory key-values:

    {
        jwt => "...",
    }

This method is for getting all valid channel access token key IDs.

When a 200 OK HTTP response is returned, a new token is issued. In this case, you may want to store the values in "key\_ids" attributes of the response object for future use.

Otherwise, you may examine the "error" attribute and "error\_description" attribute for more information about the error.

## `revoke_channel_access_token({ access_token => "..." })`

This method corresponds to the API of: [Revoke channel access token](https://developers.line.biz/en/reference/messaging-api/#revoke-channel-access-token)

The argument is a HashRef with one pair of mandatory key-values;

    { access_token => "..." }

Upon successful revocation, a 200 OK HTTP response is returned. Otherwise, you my examine the "error" attribute and "error\_description" attribute for more information about the error.

## `get_number_of_followers({ date => "..." })`

This method corresponds to the API of: [Get number of followers](https://developers.line.biz/en/reference/messaging-api/#get-number-of-followers)

The argument is a HashRef with one pair of mandatory key-values;

    { date => "20191231" }

The formate of date is "yyyyMMdd", that is, year in 4 digits, month in
2 digits, and date-of-month in 2 digits.

Upon successful invocation, a 200 OK HTTP response is
returned. Otherwise, you my examine the "error" attribute and
"error\_description" attribute for more information about the error.

The return value `$res` is a response object with the following read-only accessors
(see the API documentation for the meaning of each.)

    $res->status();          #=> Str, one of: "ready", "unready", "out_of_service"
    $res->followers();       #=> Num
    $res->targetedReaches(); #=> Num
    $res->blocks();          #=> Num

Notice that the "status" does not mean HTTP status. To inspect actual
HTTP status, invoke `$res-`http\_status()>.

## `get_user_interaction_statistics({ requestId => "..." })`

Returns statistics about how users interact with narrowcast messages or broadcast messages sent from your LINE Official Account.

See also the LINE Developers API reference of this method: [https://developers.line.biz/en/reference/messaging-api/#get-message-event](https://developers.line.biz/en/reference/messaging-api/#get-message-event)

# How to build a send message object

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

## Text type

Build a text type object.

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_text(
        text => 'Closing the distance',
    );
    $bot->reply_message($reply_token, $messages->build);

Build a text message with emojis inside:

    my $message = LINE::Bot::API::Builder::SendMessage->new();
    $message->add_text(
        text => '$ LINE Emoji $',
        emojis => [
            +{
                "index" => 0,
                "productId" => "5ac1bfd5040ab15980c9b435",
                "emojiId" => "001"
            },
            +{
                "index" => 13,
                "productId" => "5ac1bfd5040ab15980c9b435",
                "emojiId" => "002"
            }
        ]
    );

Since 2020/04/16, text messages may contain LINE emojis. They are identified by (productId, emojiId). For more details about possible values as well as how to use these emojis, please read: [https://developers.line.biz/en/reference/messaging-api/#text-message](https://developers.line.biz/en/reference/messaging-api/#text-message) first.

## Image type

Build an image type object.

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_image(
        image_url   => 'http://example.com/image.jpg',
        preview_url => 'http://example.com/image_preview.jpg',
    );
    $bot->reply_message($reply_token, $messages->build);

## Video type

Build a video type object.

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_video(
        video_url   => 'http://example.com/video.mp4',
        preview_url => 'http://example.com/video_preview.jpg',
    );
    $bot->reply_message($reply_token, $messages->build);

## Audio type

Build an audio type object.

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_audio(
        audio_url => 'http://example.com/image.m4a',
        duration  => 3601_000, # msec
    );
    $bot->reply_message($reply_token, $messages->build);

## Location type

Build a location type object.

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_location(
        title     => 'LINE Corporation.',
        address   => 'Hikarie  Shibuya-ku Tokyo 151-0002',
        latitude  => 35.6591,
        longitude => 139.7040,
    );
    $bot->reply_message($reply_token, $messages->build);

## Sticker type

Build a sticker type object.

    my $messages = LINE::Bot::API::Builder::SendMessage->new(
    )->add_sticker(
        package_id => '1',
        sticker_id => '2',
    );
    $bot->reply_message($reply_token, $messages->build);

## Imagemap type

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

## Template type

Build a template type object.
You can use a helper module for the template type.

### Buttons type

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

### Confirm type

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

### Carousel type

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

### Image Carousel type

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

## Handling Retries

For many methods that sends outgoing messages, the last parameter
`$options` is a HashRef with certain key-value pairs.

At the moment, the key 'retry\_key' is recognized. It shall be provided
to retry without causing duplicates.

For example, here's a short snippet to attemp to retry a push\_message
without resending duplicate messages:

    my $k = create_UUID_as_string();
    my $res = $bot->push_message(
        $user_id,
        $message,
        { 'retry_key' => $k }
    );

    unless ($res->is_success) {
        while ($res->http_status ne '409') {
            sleep(60);

            $res = $bot->push_message(
                $user_id,
                $message,
                { 'retry_key' => $k }
            );
        }
    }

The value of 'retry\_key' must be an UUID string. The example above
uses the `create_UUID_as_string()` function provided by [UUID::Tiny](https://metacpan.org/pod/UUID%3A%3ATiny)
and should just work.

The value of 'retry\_key' is essentially value of an HTTP header name 'X-Line-Retry-Key'. Read more about retrying a failed push\_message at: [https://developers.line.biz/en/reference/messaging-api/#retry-api-request](https://developers.line.biz/en/reference/messaging-api/#retry-api-request)

# AUTHORS

LINE Corporation.

# COPYRIGHT

Copyright 2016-2020

# LICENSE

This Software Development Kit is licensed under The Artistic License 2.0.
You may obtain a copy of the License at
https://opensource.org/licenses/Artistic-2.0

# SEE ALSO

[LINE::Bot::API::Event](https://metacpan.org/pod/LINE%3A%3ABot%3A%3AAPI%3A%3AEvent),
[https://developers.line.biz/](https://developers.line.biz/),
[https://at.line.me/](https://at.line.me/)
