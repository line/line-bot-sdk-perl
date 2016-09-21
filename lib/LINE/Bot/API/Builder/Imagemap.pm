package LINE::Bot::API::Builder::Imagemap;
use strict;
use warnings;

sub new {
    my($class, $send_message) = @_;
    bless {
        send_message => $send_message,
        actions      => +[],
    }, $class;
}

sub add_imagemap {
    my($self, %args) = @_;
    my %obj = (
        baseUrl           => $args{base_url},
        altText           => $args{alt_text},
        'baseSize.width'  => $args{base_width},
        'baseSize.height' => $args{base_height},
        actions           => $self->{actions},
    );
    $self->{send_message}->add_imagemap(%obj);
}

sub add_uri_action {
    my($self, %args) = @_;
    push @{ $self->{actions} }, +{
        type    => 'uri',
        linkUri => $args{uri},
        area    => +{
            x      => $args{area_x},
            y      => $args{area_y},
            width  => $args{area_width},
            height => $args{area_height},
        },
    };
}

sub add_message_action {
    my($self, %args) = @_;
    push @{ $self->{actions} }, +{
        type => 'message',
        text => $args{text},
        area => +{
            x      => $args{area_x},
            y      => $args{area_y},
            width  => $args{area_width},
            height => $args{area_height},
        },
    };
}

1;
