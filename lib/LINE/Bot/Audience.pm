package LINE::Bot::Audience;
use strict;
use warnings;

use LINE::Bot::API::Client;
use LINE::Bot::API::Response::Common;
use LINE::Bot::API::Response::AudienceMultipleData;
use LINE::Bot::API::Response::AudienceData;
use LINE::Bot::API::Response::AudienceGroupForUploadingUserId;
use LINE::Bot::API::Response::AudienceGroupForClickRetargeting;
use LINE::Bot::API::Response::AudienceGroupForImpressionRetargeting;
use LINE::Bot::API::Response::AudienceAuthorityLevel;

use constant {
    DEFAULT_MESSAGING_API_ENDPOINT => 'https://api.line.me/v2/bot/',
};
use Furl;
use Carp 'croak';
use URI;
use URI::QueryParam;

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

sub rename_audience {
    my ($self, $opts) = @_;

    my $res = $self->request(post => 'audienceGroup/'. $opts->{audience_group_id} . '/updateDescription', +{
        'description' => $opts->{description},
    });

    LINE::Bot::API::Response::Common->new(%{ $res });
}

sub create_audience_for_uploading {
    my ($self, $opts) = @_;

    my $res = $self->request(post => 'audienceGroup/upload', +{
        'description' => $opts->{description},
        'isIfaAudience' => $opts->{isIfaAudience},
        'uploadDescription' => $opts->{uploadDescription},
        'audiences' => $opts->{audiences},
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

sub create_audience_for_impression_based_retargeting {
    my ($self, $opts) = @_;

    my $res = $self->request(post => 'audienceGroup/imp', +{
        'description' => $opts->{description},
        'requestId' => $opts->{requestId},
    });
    LINE::Bot::API::Response::AudienceGroupForImpressionRetargeting->new(%{ $res });
}

sub get_audience_data {
    my ($self, $opts) = @_;

    my $res = $self->request(get => 'audienceGroup/' . $opts->{audienceGroupId}, +{});
    LINE::Bot::API::Response::AudienceData->new(%{ $res });
}

sub update_authority_level {
    my ($self, $opts) = @_;

    my $res = $self->request(put => 'audienceGroup/authorityLevel', +{
        'authorityLevel' => $opts->{authorityLevel},
    });
    LINE::Bot::API::Response::Common->new(%{ $res });
}

sub delete_audience {
    my ($self, $ops) = @_;

    my $res = $self->request(delete => 'audienceGroup/' . $ops->{audienceGroupId}, +{});
    LINE::Bot::API::Response::Common->new(%{ $res });
}

sub get_authority_level {
    my ($self) = @_;

    my $res = $self->request(get => 'audienceGroup/authorityLevel', +{});
    LINE::Bot::API::Response::AudienceAuthorityLevel->new(%{ $res });
}

sub get_data_for_multiple_audience {
    my ($self, $opts) = @_;

    my $uri = URI->new('audienceGroup/list');
    $uri->query_param(page => $opts->{page} // 1);
    $uri->query_param(description => $opts->{description} // '');
    $uri->query_param(status => $opts->{status} // '');
    $uri->query_param(size => $opts->{size} // 20);
    $uri->query_param(includesExternalPublicGroups => $opts->{includesExternalPublicGroups} // '');
    $uri->query_param(createRoute => $opts->{createRoute} // '');

    my $res = $self->request(get => $uri->as_string);
    LINE::Bot::API::Response::AudienceMultipleData->new(%{ $res });
}

1;
__END__

=head1 NAME

LINE::Bot::Audience

=head1 C<< rename_audience({ description => "...", audience_group_id => "..." }) >>

Renames an existing audience.

See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#set-description-audience-group>

=head1 C<< create_audience_for_uploading({ description => "...", isIfaAudience => "...", audiences => [{ id => "..." }, ... ] }) >>

Creates an audience for uploading user IDs. `description` is required parameter. the others are optional. 'audiences' is a part of this method argument, and this argument need to be ArrayRef like below.

    [
        {
            id => 123
        },
        {
            id => 124
        }
    ]


See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#create-upload-audience-group>

=head1 C<< get_data_for_multiple_audience({ page => "...", description => "...", status => "IN_PROGRESS|READY|FAILED|EXPIRED", size => "...",  includesExternalPublicGroups => "true|false", createRoute => "OA_MANAGER|MESSAGING_API" }) >>

Gets data for more than one audience.
See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#get-audience-groups>

=head1 C<< get_audience_data({ audienceGroupId => "..." }) >>

Gets audience data.
See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#get-audience-group>

About response, prepared some alias of snake_case on LINE::Bot::API::Response::AudienceData.
"jobs" is a part of response object, and it is array of hash.
See also detail response: L<https://developers.line.biz/en/reference/messaging-api/#response-25>

=head1 C<< delete_audience({ audienceGroupId => "..." }) >>

Deletes an audience.

See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#delete-audience-group>

=head1 C<< create_audience_for_click_based_retartgeting({ description => "...", requestId => "...", clickUrl => "..." }) >>

Creates an audience for click-based retargeting. You can create up to 1,000 audiences.
A click-based retargeting audience is a collection of users who have clicked a URL contained in a broadcast or narrowcast message.
Use a request ID to identify the message. The message is sent to any user who has clicked at least one link.

See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#create-click-audience-group>

=head1 C<< create_audience_for_impression_based_retargeting({ description => "...", requestId => "..." }) >>

Creates an audience for impression-based retargeting. You can create up to 1,000 audiences.
An impression-based retargeting audience is a collection of users who have viewed a broadcast or narrowcast message.
Use a request ID to specify the message. The audience will include any user who has viewed at least one message bubble.

See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#create-imp-audience-group>

=head1 C<< get_authority_level() >>

Get the authority level of the audience
See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#get-authority-level>


=cut
