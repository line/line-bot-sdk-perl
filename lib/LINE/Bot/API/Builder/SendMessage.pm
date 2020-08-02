package LINE::Bot::API::Builder::SendMessage;
use strict;
use warnings;

sub new {
    my($class, ) = @_;
    bless [], $class;
}

sub build {
    my($self, ) = @_;
    +[ @$self ];
}

sub add {
    my($self, $message) = @_;
    push @{ $self }, $message;
    $self;
}

sub add_text {
    my($self, %args) = @_;
    if (my $sender = $args{sender} // '') {
        $self->add(+{
            type => 'text',
            text => $args{text},
            sender => $args{sender},
            $args{emojis} ? (
                emojis => $args{emojis},
            ):(),
        });
    } else {
        $self->add(+{
            type => 'text',
            text => $args{text},
            $args{emojis} ? (
                emojis => $args{emojis},
            ):(),
        });
    }

    $self;
}

sub add_image {
    my($self, %args) = @_;
    if (my $sender = $args{sender}) {
        $self->add(+{
            type               => 'image',
            sender             => $args{sender},
            originalContentUrl => $args{image_url},
            previewImageUrl    => $args{preview_url},
        });
    } else {
        $self->add(+{
            type               => 'image',
            originalContentUrl => $args{image_url},
            previewImageUrl    => $args{preview_url},
        });
    }

    $self;
}

sub add_video {
    my($self, %args) = @_;
    if (my $sender = $args{sender}) {
        $self->add(+{
            type               => 'video',
            sender             => $args{sender},
            originalContentUrl => $args{video_url},
            previewImageUrl    => $args{preview_url},
        });
    } else {
        $self->add(+{
            type               => 'video',
            originalContentUrl => $args{video_url},
            previewImageUrl    => $args{preview_url},
        });
    }

    $self;
}

sub add_audio {
    my($self, %args) = @_;
    if (my $sender = $args{sender}) {
        $self->add(+{
            type               => 'audio',
            sender             => $args{sender},
            originalContentUrl => $args{audio_url},
            duration           => $args{duration},
        });
    } else {
        $self->add(+{
            type               => 'audio',
            originalContentUrl => $args{audio_url},
            duration           => $args{duration},
        });
    }

    $self;
}

sub add_location {
    my($self, %args) = @_;
    if (my $sender = $args{sender}) {
        $self->add(+{
            type      => 'location',
            sender    => $args{sender},
            title     => $args{title},
            address   => $args{address},
            latitude  => $args{latitude},
            longitude => $args{longitude},
        });
    } else {
        $self->add(+{
            type      => 'location',
            title     => $args{title},
            address   => $args{address},
            latitude  => $args{latitude},
            longitude => $args{longitude},
        });
    }

    $self;
}

sub add_sticker {
    my($self, %args) = @_;
    if (my $sender = $args{sender}) {
        $self->add(+{
            type      => 'sticker',
            sender    => $args{sender},
            packageId => $args{package_id},
            stickerId => $args{sticker_id},
        });
    } else {
        $self->add(+{
            type      => 'sticker',
            packageId => $args{package_id},
            stickerId => $args{sticker_id},
        });
    }

    $self;
}

# If you want this method to use, I recommend using LINE::Bot::API::Builder::ImagemapMessage class for you.
sub add_imagemap {
    my($self, $imagemap) = @_;
    $self->add($imagemap);
}

# If you want this method to use, I recommend using LINE::Bot::API::Builder::TemplateMessage class for you.
sub add_template {
    my($self, $template) = @_;
    $self->add($template);
}

1;
