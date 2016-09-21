package LINE::Bot::API::Builder::SendMessage;
use strict;
use warnings;

use LINE::Bot::API::Builder::Imagemap;

sub new {
    my($class, %args) = @_;
    bless {
        bot      => $args{bot},
        type     => $args{type},
        messages => [],
    }, $class;
}

sub send {
    my($self, $target_id) = @_;
    if ($self->{type} eq 'reply') {
        $self->{bot}->reply_message(
            replyToken => $target_id,
            messages   => $self->{messages},
        );
    } else {
        # push message
        $self->{bot}->push_message(
            to       => $target_id,
            messages => $self->{messages},
        );
    }
}

sub add_text {
    my($self, %args) = @_;
    push @{ $self->{messages} }, +{
        type => 'text',
        text => $args{text},
    };
    $self;
}

sub add_image {
    my($self, %args) = @_;
    push @{ $self->{messages} }, +{
        type               => 'image',
        originalContentUrl => $args{image_url},
        previewImageUrl    => $args{preview_url},
    };
    $self;
}

sub add_video {
    my($self, %args) = @_;
    push @{ $self->{messages} }, +{
        type               => 'video',
        originalContentUrl => $args{video_url},
        previewImageUrl    => $args{preview_url},
    };
    $self;
}

sub add_audio {
    my($self, %args) = @_;
    push @{ $self->{messages} }, +{
        type               => 'audio',
        originalContentUrl => $args{audio_url},
        duration           => $args{duration},
    };
    $self;
}

sub add_location {
    my($self, %args) = @_;
    push @{ $self->{messages} }, +{
        type      => 'location',
        title     => $args{text},
        address   => $args{address},
        latitude  => $args{latitude},
        longitude => $args{longitude},
    };
    $self;
}

sub add_sticker {
    my($self, %args) = @_;
    push @{ $self->{messages} }, +{
        type      => 'sticker',
        packageId => $args{package_id},
        stickerId => $args{sticker_id},
    };
    $self;
}

sub add_imagemap {
    my($self, %imagemap) = @_;
    push @{ $self->{messages} }, +{
        %imagemap,
        type => 'imagemap',
    };
    $self;
}

sub imagemap_builder {
    my($self, ) = @_;
    LINE::Bot::API::Builder::Imagemap->new($self);
}

1;
