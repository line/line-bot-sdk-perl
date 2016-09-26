package LINEBotFramework;
use strict;
use warnings;

use Module::Load;
use Text::Xslate;

use LINEBotFramework::Request;
use LINEBotFramework::Response;
use LINEBotFramework::Dispatcher ();

sub new {
    my($class, %args) = @_;

    my $xslate_config = $args{xslate_config};
    $xslate_config->{type}   ||= 'text';
    $xslate_config->{syntax} ||= 'TTerse';
    $xslate_config->{module} ||= [ 'Text::Xslate::Bridge::Star' ];
    my $xslate        = Text::Xslate->new(%{ $xslate_config });

    my $base_class = $args{base_class};
    load $base_class;

    bless {
        bot            => $args{bot},
        xslate         => $xslate,
        base_class     => $base_class,
        base_obj       => $base_class->new,
        loaded_classes => +{},
    }, $class;
}

sub load_class {
    my($self, $name) = @_;
    $self->{loaded_classes}{$name} ||= do {
        my $klass = join '::', $self->{base_class}, $name;
        load $klass;
        $klass;
    };
}

sub validate_signature {
    my($self, $json, $signature) = @_;
    $self->{bot}->validate_signature($json, $signature);
}

sub dispatcher {
    my($self, $json) = @_;

    my $events = $self->{bot}->parse_events_from_json($json);
    for my $event (@{ $events }) {
        if ($event->is_message_event) {
            $self->dispatcher_message($event);
        } else {
            $self->dispatcher_operation($event);
        }
    }
}

sub dispatcher_operation {
    my($self, $event, @args) = @_;

    my $req = LINEBotFramework::Request->new(
        bot     => $self->{bot},
        event   => $event,
        session => +{},
    );

    if ($self->load_class('Operation')->can('before_hook')) {
        $self->load_class('Operation')->before_hook($req, @args);
    }

    my $res;
    if ($event->is_follow_event) {
        $res = $self->load_class('Operation')->on_follow($req, @args);
    } elsif ($event->is_unfollow_event) {
        $res = $self->load_class('Operation')->on_unfollow($req, @args);
    } elsif ($event->is_join_event) {
        $res = $self->load_class('Operation')->on_join($req, @args);
    } elsif ($event->is_leave_event) {
        $res = $self->load_class('Operation')->on_leave($req, @args);
    } elsif ($event->is_postback_event) {
        $res = $self->load_class('Operation')->on_postback($req, @args);
    } elsif ($event->is_beacon_detection_event) {
        $res = $self->load_class('Operation')->on_beacon_detection($req, @args);
    }

    return $self->response_finalize($req, $res);
}

sub dispatcher_message {
    my($self, $event, @args) = @_;

    my $source = $self->_extract_source_data($event);
    my($context, $session) = $self->{base_obj}->get_context($source->{type}, $source->{from_id});

    my $req = LINEBotFramework::Request->new(
        bot     => $self->{bot},
        event   => $event,
        context => $context,
        session => $session,
    );

    my $route = $self->exec_message_router($req);

    my $res;
    if ($route) {
        if ($route->{mode} eq 'static') {
            # static mode
            $res = LINEBotFramework::Response->new;
            $route->{template_vars} //= +{};
            $route->{template_vars}{args} = \@args;
            $res->send_text(
                text          => $route->{text},
                page          => $route->{page},
                template_vars => $route->{template_vars},
            );
            $res->next_context($route->{next_context});
        } elsif ($route->{mode} eq 'dynamic') {
            # use context handler
            my $method = $route->{method};
            $res = $self->load_class($route->{class} || 'Default')->$method($req, @args);
        }
    }

    return $self->response_finalize($req, $res);
}


sub exec_message_router {
    my($self, $req) = @_;
    my $event = $req->event;
    my $route;

    my $text;
    if ($event->is_text_message) {
        $text = $event->text;
    }

    local $_                                     = $text;
    local $LINEBotFramework::Dispatcher::TEXT    = $text;
    local $LINEBotFramework::Dispatcher::CONTEXT = $req->context;
    local $LINEBotFramework::Dispatcher::EVENT   = $event;
    local $LINEBotFramework::Dispatcher::SESSION = $req->session;
    my $ret = $self->load_class('Dispatcher')->dispatch($req->context, $event, $req->session);
    if ($ret) {
        if (ref($ret) eq 'HASH') {
            $route = $ret;
            $route->{next_context} ||= 'default';
            $route->{mode}         ||= 'static';
        } elsif (! ref($ret) && (my($class, $method) = $ret =~ /^(.+)#(.+)$/)) {
            $route = +{
                mode   => 'dynamic',
                class  => $class,
                method => $method,
            };
        }
    }

    return $route;
}

sub response_finalize {
    my($self, $req, $res) = @_;
    return unless $res;
    my $event = $req->event;

    my $reply_token = $event->reply_token;
    if ($reply_token) {
        my $ret = $res->finalize(
            reply_token => $reply_token,
            bot         => $self->{bot},
            xslate      => $self->{xslate},
            base_obj    => $self->{base_obj},
        );
        return unless $ret;
    }

    # save context
    my $next_context = $res->next_context;
    unless ($next_context eq 'self') {
        my $source = $self->_extract_source_data($event);
        $self->{base_obj}->set_context($source->{type}, $source->{from_id}, $next_context, $req->session);
    }

    return 1;
}

sub _extract_source_data {
    my($self, $event) = @_;

    my $source_type = 'user';
    my $from_id;
    if ($event->is_user_event) {
        $from_id = $event->user_id;
    } elsif ($event->is_group_event) {
        $source_type = 'group';
        $from_id     = $event->group_id;
    } elsif ($event->is_room_event) {
        $source_type = 'room';
        $from_id     = $event->room_id;
    }

    return +{
        type    => $source_type,
        from_id => $from_id,
    };
}

1;

__END__

=head1 NAME

LINEBotFramework - A bot framework example

=head1 COPYRIGHT & LICENSE

Copyright 2016 LINE Corporation

This Software Development Kit is licensed under The Artistic License 2.0.
You may obtain a copy of the License at
https://opensource.org/licenses/Artistic-2.0

=head1 SEE ALSO

L<interactive-bot.psgi>

=cut
