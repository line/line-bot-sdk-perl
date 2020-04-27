package LINE::Bot::Audience;
use strict;
use warnings;

use LINE::Bot::API::Client;
use LINE::Bot::API::Response::AudienceGroupForUploadingUserId;
use LINE::Bot::API::Response::AudienceGroupForClickRetargeting;

use constant {
    DEFAULT_MESSAGING_API_ENDPOINT => 'https://api.line.me/v2/bot/',
};
use Furl;
use Carp 'croak';

sub new {
    my($class, %args) = @_;

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

sub create_audience_for_uploading {
    my ($self, $opts) = @_;

    my $res = $self->request(post => 'audienceGroup/upload', +{
        'description' => $opts->{description},
        'isIfaAudience' => $opts->{isIfaAudience},
        'uploadDescription' => $opts->{uploadDescription},
        'audiences' => $opts->{audiences},
        'audiences[].id' => $opts->{audiences_id},
    });
    LINE::Bot::API::Response::AudienceGroupForUploadingUserId->new(%{ $res });
}

sub create_audience_for_click_based_retartgeting {
    my ($self, $opts) = @_;

    my $res = $self->request(post => 'audienceGroup/click', +{
        'description' => $opts->{description},
        'requestId' => $opts->{requestId},
        'clickUrl' => $opts->{clickUrl},
    });
    LINE::Bot::API::Response::AudienceGroupForClickRetargeting->new(%{ $res });
}

1;
__END__

=head1 NAME

LINE::Bot::Audience

=head1 C<< create_audience_for_uploading({ description => "...", isIfaAudience => "...", audience => [...], audiences_id => "..." }) >>
Creates an audience for uploading user IDs. You can create up to 1,000 audiences.

See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#create-upload-audience-group>

=head1 C<< create_audience_for_click_based_retartgeting({ description => "...", requestId => "...", clickUrl => "..." }) >>
Creates an audience for click-based retargeting. You can create up to 1,000 audiences.
A click-based retargeting audience is a collection of users who have clicked a URL contained in a broadcast or narrowcast message.
Use a request ID to identify the message. The message is sent to any user who has clicked at least one link.

See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#create-click-audience-group>

=cut
