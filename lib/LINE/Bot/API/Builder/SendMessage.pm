package LINE::Bot::API::Builder::SendMessage;
use strict;
use warnings;

use LINE::Bot::API::Constants;

sub build_text {
    my($self, %args) = @_;
    +(
        contentType => CONTENT_TEXT,
        text        => $args{text},
    );
}

sub build_image {
    my($self, %args) = @_;
    +(
        contentType        => CONTENT_IMAGE,
        text               => $args{text},
        originalContentUrl => $args{image_url},
        previewImageUrl    => $args{preview_url},
    );
}

sub build_video {
    my($self, %args) = @_;
    +(
        contentType        => CONTENT_VIDEO,
        text               => $args{text},
        originalContentUrl => $args{video_url},
        previewImageUrl    => $args{preview_url},
    );
}

sub build_audio {
    my($self, %args) = @_;
    +(
        contentType        => CONTENT_AUDIO,
        text               => $args{text},
        originalContentUrl => $args{audio_url},
        contentMetadata    => {
            AUDLEN => $args{duration},
        },
    );
}

sub build_location {
    my($self, %args) = @_;
    +(
        contentType => CONTENT_LOCATION,
        text        => $args{text},
        location    => {
            title     => $args{text},
            address   => $args{address},
            latitude  => $args{latitude},
            longitude => $args{longitude},
        },
    );
}

sub build_sticker {
    my($self, %args) = @_;
    +(
        contentType        => CONTENT_STICKER,
        contentMetadata    => {
            STKID    => $args{stkid},
            STKPKGID => $args{stkpkgid},
            STKVER   => $args{stkver},
        },
    );
}

1;
