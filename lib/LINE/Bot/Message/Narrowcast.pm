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

C<$message> is a HashRef with key/values for as specified in API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#send-narrowcast-message>.  nested keys are represented in the dotted notations.

C<$recipient> should be an HashRef with keys/values as specified in the documentation of L<Recipient objects|https://developers.line.biz/en/reference/messaging-api/#narrowcast-recipient>. It can be either audience object or redelivery object. You can specify up to 10 recipients per request based on a combination of criteria using logical operator objects.

C<$demographic> should be an HashRef with key/values as specified in the documentation of L<Demagraphic filter object|https://developers.line.biz/en/reference/messaging-api/#narrowcast-demographic-filter>. It represent criteria (e.g. age, gender, OS, region, and friendship duration) on which to filter the list of recipients. You can filter recipients based on a combination of different criteria using logical operator objects.

C<$limit> should be an HashRef with these optional key-value pairs:

    max: Number
    upToRemainingQuota: Boolean

For example:

    {
        "max" => 42,
        "upToRemainingQuota": JSON::true,
    }

Noted here that the value for "upToRemainingQuotae" must be one of the boolean values recognizied by L<JSON::XS>. See also L<JSON::XS/"other references">.

Messages cannot be sent to groups or rooms.

The last parameter C<$options> is an HashRef with a list of key-values
pairs to fine-tune the behaviour of this message. At the moment, the
only defined configurable option is C<"retry_key">, which requires an
UUID string for its value. See the section L<LINE::Bot::API/"Handling Retries"> for the meaning of this particular option.

=head3 C<< get_narrowcast_message_status($request_id) >>

Gets the status of a narrowcast message.

See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#get-narrowcast-progress-status>

=cut
