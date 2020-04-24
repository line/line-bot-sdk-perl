package LINE::Bot::Audience;
use strict;
use warnings;

use LINE::Bot::API::Client;
use LINE::Bot::API::Response::AudienceGroup;
use LINE::Bot::API::Response::AudienceMultipleData;

use constant {
    DEFAULT_MESSAGING_API_ENDPOINT => 'https://api.line.me/v2/bot/',
};
use Furl;
use Carp 'croak';
use URI::Escape;

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
    LINE::Bot::API::Response::AudienceGroup->new(%{ $res });
}

sub get_data_for_multiple_audience {
    my ($self, $opts) = @_;

    my $param = [];
    push @$param, 'page=' . ($opts->{page} // 1);
    push @$param, 'description=' . uri_escape_utf8($opts->{description} // '');
    push @$param, 'status=' . uri_escape_utf8($opts->{status} // '');
    push @$param, 'size=' .  ($opts->{size} // 20);
    push @$param, 'includesExternalPublicGroups=' . ($opts->{includesExternalPublicGroups} // '');
    push @$param, 'createRoute=' . ($opts->{createRoute} // '');

    my $res = $self->request(get => 'audienceGroup/list?' . join('&', @$param));
    LINE::Bot::API::Response::AudienceMultipleData->new(%{ $res });
}

1;
__END__

=head1 NAME

LINE::Bot::Audience

=head1 C<< create_audience_for_uploading({ description => "...", isIfaAudience => "...", audience => [...], audiences_id => "..." }) >>
Creates an audience for uploading user IDs.

See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#create-upload-audience-group>

=head1 C<< get_data_for_multiple_audience({ page => "...", description => "...", status => "IN_PROGRESS|READY|FAILED|EXPIRED", size => "...",  includesExternalPublicGroups => "true|false", createRoute => "OA_MANAGER|MESSAGING_API" }) >>
Gets data for more than one audience.
See also the API reference of this method: L<https://developers.line.biz/en/reference/messaging-api/#get-audience-groups>

=cut
