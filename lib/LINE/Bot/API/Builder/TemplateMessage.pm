package LINE::Bot::API::Builder::TemplateMessage;
use strict;
use warnings;

sub new_buttons {
    my($class, %args) = @_;
    LINE::Bot::API::Builder::TemplateMessage::Buttons->new(%args);
}

sub new_confirm {
    my($class, %args) = @_;
    LINE::Bot::API::Builder::TemplateMessage::Confirm->new(%args);
}

sub new_carousel {
    my($class, %args) = @_;
    LINE::Bot::API::Builder::TemplateMessage::Carousel->new(%args);
}

sub new_image_carousel {
    my($class, %args) = @_;
    LINE::Bot::API::Builder::TemplateMessage::ImageCarousel->new(%args);
}


package LINE::Bot::API::Builder::TemplateMessage::ActionBase {

    sub add_action {
        my($self, $action) = @_;
        push @{ $self->_actions }, $action;
        $self;
    }

    sub add_postback_action {
        my($self, %args) = @_;
        $self->add_action(+{
            type  => 'postback',
            label => $args{label},
            data  => $args{data},
            text  => $args{text},
        });
    }

    sub add_message_action {
        my($self, %args) = @_;
        $self->add_action(+{
            type  => 'message',
            label => $args{label},
            text  => $args{text},
        });
    }

    sub add_uri_action {
        my($self, %args) = @_;
        $self->add_action(+{
            type  => 'uri',
            label => $args{label},
            uri   => $args{uri},
        });
    }
}

package LINE::Bot::API::Builder::TemplateMessage::Buttons {
    use parent -norequire, 'LINE::Bot::API::Builder::TemplateMessage::ActionBase';

    sub new {
        my($class, %args) = @_;
        bless {
            type     => 'template',
            altText  => $args{alt_text},
            template => +{
                type              => 'buttons',
                thumbnailImageUrl => $args{image_url},
                title             => $args{title},
                text              => $args{text},
                actions           => $args{actions} // +[],
            },
        }, $class;
    }

    sub build {
        my($self, ) = @_;
        +{ %{ $self } };
    }

    sub _actions { $_[0]{template}{actions} }
}

package LINE::Bot::API::Builder::TemplateMessage::Confirm {
    use parent -norequire, 'LINE::Bot::API::Builder::TemplateMessage::ActionBase';

    sub new {
        my($class, %args) = @_;
        bless {
            type     => 'template',
            altText  => $args{alt_text},
            template => +{
                type    => 'confirm',
                text    => $args{text},
                actions => $args{actions} // +[],
            },
        }, $class;
    }

    sub build {
        my($self, ) = @_;
        +{ %{ $self } };
    }

    sub _actions { $_[0]{template}{actions} }
}

package LINE::Bot::API::Builder::TemplateMessage::Carousel {

    sub new {
        my($class, %args) = @_;
        bless {
            type     => 'template',
            altText  => $args{alt_text},
            template => +{
                type    => 'carousel',
                columns => $args{columns} // +[],
            },
        }, $class;
    }

    sub build {
        my($self, ) = @_;
        +{ %{ $self } };
    }

    sub add_column {
        my($self, $column) = @_;
        push @{ $self->{template}{columns} }, $column;
        $self;
    }
}

package LINE::Bot::API::Builder::TemplateMessage::ImageCarousel {

    sub new {
        my($class, %args) = @_;
        bless {
            type     => 'template',
            altText  => $args{alt_text},
            template => +{
                type    => 'image_carousel',
                columns => $args{columns} // +[],
            },
        }, $class;
    }

    sub build {
        my($self, ) = @_;
        +{ %{ $self } };
    }

    sub add_column {
        my($self, $column) = @_;
        push @{ $self->{template}{columns} }, $column;
        $self;
    }
}

package LINE::Bot::API::Builder::TemplateMessage::Column {
    use parent -norequire, 'LINE::Bot::API::Builder::TemplateMessage::ActionBase';

    sub new {
        my($class, %args) = @_;
        bless {
            thumbnailImageUrl => $args{image_url},
            title             => $args{title},
            text              => $args{text},
            actions           => $args{actions} // +[],
        }, $class;
    }

    sub build {
        my($self, ) = @_;
        +{ %{ $self } };
    }

    sub _actions { $_[0]{actions} }
}

package LINE::Bot::API::Builder::TemplateMessage::ImageColumn {
    use parent -norequire, 'LINE::Bot::API::Builder::TemplateMessage::ActionBase';

    sub new {
        my($class, %args) = @_;
        bless {
            imageUrl => $args{image_url},
            action   => undef,
        }, $class;
    }

    sub build {
        my($self, ) = @_;
        +{ %{ $self } };
    }

    sub add_action {
        my($self, $action) = @_;
        $self->{action} = $action;
        $self;
    }
}

1;
