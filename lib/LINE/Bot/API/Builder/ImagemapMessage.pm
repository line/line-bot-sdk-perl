package LINE::Bot::API::Builder::ImagemapMessage;
use strict;
use warnings;

sub new {
    my($class, %args) = @_;
    my %o = (
        type     => 'imagemap',
        baseUrl  => $args{base_url},
        altText  => $args{alt_text},
        baseSize => +{
            width  => $args{base_width},
            height => $args{base_height},
        },
        actions  => $args{actions} // [],
    );

    if ($args{video}) {
        $o{video} = {};
        for my $attr (qw(originalContentUrl previewImageUrl)) {
            $o{video}{$attr} = $args{video}{$attr};
        }
        for my $attr (qw(x y width height)) {
            $o{video}{area}{$attr} = $args{video}{area}{$attr};
        }

        if ($args{video}{externalLink}) {
            for my $attr (qw(label linkUri)) {
                $o{video}{externalLink}{$attr} = $args{video}{externalLink}{$attr};
            }
        }
    }

    return bless \%o, $class;
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
