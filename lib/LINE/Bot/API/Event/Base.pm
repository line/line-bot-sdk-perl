package LINE::Bot::API::Event::Base;
use strict;
use warnings;

use Carp 'croak';

sub new {
    my($class, %args) = @_;
    bless { %args }, $class;
}

# Accessors for Event-level properties. https://developers.line.biz/en/reference/messaging-api/#common-properties
sub type      { $_[0]->{type}      }
sub mode      { $_[0]->{mode}      }
sub timestamp { $_[0]->{timestamp} }
sub webhook_event_id { $_[0]->{webhookEventId} }

# Whether the webhook event is a redelivered one or not. 
# https://developers.line.biz/en/docs/messaging-api/receiving-messages/#redelivered-webhooks
sub is_redelivery { $_[0]->{deliveryContext}{isRedelivery} }

# Unfollow and Leave events don't have this
sub reply_token { $_[0]->{replyToken} }

# type
sub is_message_event          { 0 }
sub is_follow_event           { 0 }
sub is_unfollow_event         { 0 }
sub is_join_event             { 0 }
sub is_leave_event            { 0 }
sub is_member_join_event      { 0 }
sub is_member_leave_event     { 0 }
sub is_postback_event         { 0 }
sub is_beacon_detection_event { 0 }
sub is_device_link_event      { 0 }
sub is_device_unlink_event    { 0 }
sub is_account_link_event     { 0 }
sub is_unsend_event { 0 }
sub is_video_viewing_complete_event { 0 }
sub is_unknown_event { 0 }

# source field
sub is_user_event  { $_[0]->{source}{type} eq 'user' }
sub is_group_event { $_[0]->{source}{type} eq 'group' }
sub is_room_event  { $_[0]->{source}{type} eq 'room' }

sub user_id { $_[0]->{source}{userId} }

sub group_id {
    my $self = shift;
    croak 'This event source is not a group type.' unless $self->is_group_event;
    $self->{source}{groupId};
}

sub room_id {
    my $self = shift;
    croak 'This event source is not a room type.' unless $self->is_room_event;
    $self->{source}{roomId};
}

1;
