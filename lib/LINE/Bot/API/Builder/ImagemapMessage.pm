package LINE::Bot::API::Builder::ImagemapMessage;
use strict;
use warnings;

sub new {
    my($class, %args) = @_;
    bless {
        type     => 'imagemap',
        baseUrl  => $args{base_url},
        altText  => $args{alt_text},
        baseSize => +{
            width  => $args{base_width},
            height => $args{base_height},
        },
        actions  => $args{actions} // [],
    }, $class;
}

sub build {
    my($self, ) = @_;
    +{ %{ $self } };
}

sub add_action {
    my($self, $action) = @_;
    push @{ $self->{actions} }, $action;
    $self;
}

sub add_uri_action {
    my($self, %args) = @_;
    $self->add_action(+{
        type    => 'uri',
        linkUri => $args{uri},
        area    => +{
            x      => $args{area_x},
            y      => $args{area_y},
            width  => $args{area_width},
            height => $args{area_height},
        },
    });
}

sub add_message_action {
    my($self, %args) = @_;
    $self->add_action(+{
        type => 'message',
        text => $args{text},
        area => +{
            x      => $args{area_x},
            y      => $args{area_y},
            width  => $args{area_width},
            height => $args{area_height},
        },
    });
}

1;
