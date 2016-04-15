package LINE::Bot::API::Builder::MultipleMessage;
use strict;
use warnings;

use LINE::Bot::API::Constants;
use LINE::Bot::API::Builder::SendMessage;

sub new {
    my($class, $bot) = @_;
    bless {
        bot      => $bot,
        messages => [],
    }, $class;
}

sub send_messages {
    my($self, %args) = @_;
    $args{message_notified} //= 0;
    $self->{bot}->_message_post({
        to        => $args{to_mid},
        eventType => EVENT_TYPE_SENDING_MULTIPLE_MESSAGE,
        content   => {
            messageNotified => $args{message_notified},
            messages        => $self->{messages},
        },
    });
}

sub add_text {
    my($self, %args) = @_;
    push @{ $self->{messages} }, +{ LINE::Bot::API::Builder::SendMessage->build_text(%args) };
    $self;
}

sub add_image {
    my($self, %args) = @_;
    push @{ $self->{messages} }, +{ LINE::Bot::API::Builder::SendMessage->build_image(%args) };
    $self;
}

sub add_video {
    my($self, %args) = @_;
    push @{ $self->{messages} }, +{ LINE::Bot::API::Builder::SendMessage->build_video(%args) };
    $self;
}

sub add_audio {
    my($self, %args) = @_;
    push @{ $self->{messages} }, +{ LINE::Bot::API::Builder::SendMessage->build_audio(%args) };
    $self;
}

sub add_location {
    my($self, %args) = @_;
    push @{ $self->{messages} }, +{ LINE::Bot::API::Builder::SendMessage->build_location(%args) };
    $self;
}

sub add_sticker {
    my($self, %args) = @_;
    push @{ $self->{messages} }, +{ LINE::Bot::API::Builder::SendMessage->build_sticker(%args) };
    $self;
}

1;
