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
    $self->add(+{
        type => 'text',
        text => $args{text},
    });
}

sub add_image {
    my($self, %args) = @_;
    $self->add(+{
        type               => 'image',
        originalContentUrl => $args{image_url},
        previewImageUrl    => $args{preview_url},
    });
}

sub add_video {
    my($self, %args) = @_;
    $self->add(+{
        type               => 'video',
        originalContentUrl => $args{video_url},
        previewImageUrl    => $args{preview_url},
    });
}

sub add_audio {
    my($self, %args) = @_;
    $self->add(+{
        type               => 'audio',
        originalContentUrl => $args{audio_url},
        duration           => $args{duration},
    });
}

sub add_location {
    my($self, %args) = @_;
    $self->add(+{
        type      => 'location',
        title     => $args{title},
        address   => $args{address},
        latitude  => $args{latitude},
        longitude => $args{longitude},
    });
}

sub add_sticker {
    my($self, %args) = @_;
    $self->add(+{
        type      => 'sticker',
        packageId => $args{package_id},
        stickerId => $args{sticker_id},
    });
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
