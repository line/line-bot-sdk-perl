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
    my ($self, $messages, $recipient, $demographic, $limit, $options) = @_;

    my @headers = ();
    if ($options && defined($options->{'retry_key'})) {
        push @headers, 'X-Line-Retry-Key' => $options->{'retry_key'};
    }

    my $res = $self->request(
        post => 'message/narrowcast',
        \@headers,
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

=head2 Methods

=head3 C<< send_message($messages, $recipient, $demographic, $limit, $options) >>

Sends a push message to multiple users.
You can specify recipients using attributes (such as age, gender, OS, and region) or by retargeting (audiences).
Messages cannot be sent to groups or rooms.

The last parameter C<$options> is an HashRef with a list of key-values
pairs to fine-tune the behaviour of this message. At the moment, the
only defined configurable option is C<"retry_key">, which requires an
UUID string for its value. See the section L<LINE::Bot::API/"Handling Retries"> for the meaning of this particular option.

See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#send-narrowcast-message>

=head3 C<< get_narrowcast_message_status($request_id) >>

Gets the status of a narrowcast message.

See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#get-narrowcast-progress-status>

=cut
