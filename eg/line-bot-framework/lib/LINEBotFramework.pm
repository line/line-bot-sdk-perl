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

sub signature_validation {
    my($self, $json, $signature) = @_;
    $self->{bot}->signature_validation($json, $signature);
}

sub dispatcher {
    my($self, $json) = @_;

    my $receives = $self->{bot}->create_receives_from_json($json);
    for my $receive (@{ $receives }) {
        if ($receive->is_operation) {
            $self->dispatcher_operation($receive);
        } elsif ($receive->is_message) {
            $self->dispatcher_message($receive);
        }
    }
}

sub dispatcher_operation {
    my($self, $operation, @args) = @_;

    my $req = LINEBotFramework::Request->new(
        bot       => $self->{bot},
        operation => $operation,
        session   => +{},
    );

    if ($self->load_class('Operation')->can('before_hook')) {
        $self->load_class('Operation')->before_hook($req, @args);
    }

    my $res;
    if ($operation->is_add_contact) {
        $res = $self->load_class('Operation')->add_contact($req, @args);
    } elsif ($operation->is_block_contact) {
        $res = $self->load_class('Operation')->block_contact($req, @args);
    }

    return $self->response_finalize($req, $res);
}

sub dispatcher_message {
    my($self, $message, @args) = @_;

    my($context, $session) = $self->{base_obj}->get_context($message->from_mid);

    my $req = LINEBotFramework::Request->new(
        bot     => $self->{bot},
        message => $message,
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
    my $route;

    my $text;
    if ($req->message->is_text) {
        $text = $req->message->text;
    }

    local $_                                     = $text;
    local $LINEBotFramework::Dispatcher::TEXT    = $text;
    local $LINEBotFramework::Dispatcher::CONTEXT = $req->context;
    local $LINEBotFramework::Dispatcher::MESSAGE = $req->message;
    local $LINEBotFramework::Dispatcher::SESSION = $req->session;
    my $ret = $self->load_class('Dispatcher')->dispatch($req->context, $req->message, $req->session);
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

    my $from_mid = $req->message ? $req->message->from_mid : $req->operation ? $req->operation->from_mid : undef;
    return unless $from_mid;

    my $ret = $res->finalize(
        to_mid   => $from_mid,
        bot      => $self->{bot},
        xslate   => $self->{xslate},
        base_obj => $self->{base_obj},
    );
    return unless $ret;

    if ($req->message || $req->operation->is_add_contact) {
        # save context
       my $next_context = $res->next_context;
        unless ($next_context eq 'self') {
            $self->{base_obj}->set_context($from_mid, $next_context, $req->session);
        }
    }

    return 1;
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
