package LINE::Bot::Message::Narrowcast;
use strict;
use warnings;

use LINE::Bot::API::Client;
use LINE::Bot::API::Response::NarrowcastStatus;

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

sub get_narrowcast_message_status {
    my ($self, $request_id) = @_;

    my $res = $self->request(
        get => "message/progress/narrowcast?requestId=${request_id}"
    );

    LINE::Bot::API::Response::NarrowcastStatus->new(%{ $res });
}

1;
__END__

=head1 NAME

LINE::Bot::Message::Narrowcast

=head1 C<< send_message($messages, $recipient, $demographic, $limit) >>

Sends a push message to multiple users.
You can specify recipients using attributes (such as age, gender, OS, and region) or by retargeting (audiences).
Messages cannot be sent to groups or rooms.

See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#send-narrowcast-message>

=head1 C<< get_narrowcast_message_status($request_id) >>

Gets the status of a narrowcast message.

See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#get-narrowcast-progress-status>

=cut
