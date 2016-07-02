package LINE::Bot::API::Builder::RichMessage;
use strict;
use warnings;

use overload '""' => \&build;

use Carp 'croak';
use JSON::XS;

my $JSON = JSON::XS->new->ascii;

sub new {
    my($class, %args) = @_;

    my $height = $args{height};
    croak "Rich Message canvas's height should be less than or equals 2080px" if $height > 2080;

    bless {
        bot         => $args{bot},
        markup      => {
            canvas => {
                height       => $height+0, # Integer value. Max value is 2080px.
                width        => 1040,      # Integer fixed value: 1040.
                initialScene => 'scene1',  # Fixed string "scene1".
            },
            images  => +{
                image1 => +{
                    x => 0,       # Fixed 0.
                    y => 0,       # Fixed 0.
                    w => 1040,    # Integer fixed value: 1040.
                    h => $height, # Integer value. Max value is 2080px.
                },
            },
            actions => +{},
            scenes  => +{
                scene1 => +{
                    draws     => [
                        +{
                            image => 'image1', # Use the image ID "image1".
                            x     => 0,        # Fixed 0.
                            y     => 0,        # Fixed 0.
                            w     => 1040,     # Integer value. Any one of 1040, 700, 460, 300, 240. This value must be same as the image width.
                            h     => $height,  # Integer value. Max value is 2080px.
                        },
                    ],
                    listeners => [],
                },
            },
        },

    }, $class;
}


sub send_message {
    my($self, %args) = @_;
    $self->{bot}->send_rich_message(
         to_mid      => $args{to_mid},
         to_type     => $args{to_type},
         image_url   => $args{image_url},
         alt_text    => $args{alt_text},
         markup_json => $self->build,
     );
}

sub build {
    my $self = shift;
    $JSON->encode($self->{markup});
}

sub set_action {
    my($self, $name, %args) = @_;

    my $type = $args{type} || 'web';
    my %obj  = (
        type   => $type,
    );
    if ($type eq 'web') {
        $obj{text}   = $args{text};
        $obj{params} = +{
            linkUri => $args{link_uri},
        };
    } elsif ($type eq 'sendMessage') {
        $obj{params} = +{
            text => $args{text},
        };
    }

    $self->{markup}{actions}{$name} = +{ %obj };

    $self;
}

sub add_listener {
    my($self, %args) = @_;

    push @{ $self->{markup}{scenes}{scene1}{listeners} }, +{
        type   => 'touch', # Fixed "touch".
        params => [$args{x}, $args{y}, $args{width}, $args{height}],
        action => $args{action},
    };

    $self;
}

1;
