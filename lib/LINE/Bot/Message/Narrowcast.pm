package LINE::Bot::Message::Narrowcast;
use strict;
use warnings;

use LINE::Bot::API::Client;

use constant {
    DEFAULT_MESSAGING_API_ENDPOINT => 'https://api.line.me/v2/bot/',
};

sub new {
    my ($class, %args) = @_;

    my $client = LINE::Bot::API::Client->new(%args);
    bless {
        client               => $client,
        channel_secret       => $args{channel_secret},
        channel_access_token => $args{channel_access_token},
        messaging_api_endpoint => $args{messaging_api_endpoint} // DEFAULT_MESSAGING_API_ENDPOINT,
    }, $class;
}

sub request {
    my ($self, $method, $path, @payload) = @_;

    return $self->{client}->$method(
        $self->{messaging_api_endpoint} .  $path,
        @payload,
    );
}

sub send_message {
    my ($self, $messages, $recipient, $demographic, $limit) = @_;

    my $res = $self->request(
        post => 'message/narrowcast',
        +{
            messages => $messages,
            recipient => $recipient,
            filter => {
                demographic => $demographic,
            },
            limit => $limit,
        },
    );

    LINE::Bot::API::Response::Common->new(%{ $res });
}

1;
