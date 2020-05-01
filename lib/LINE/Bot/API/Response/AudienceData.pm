package LINE::Bot::API::Response::AudienceData;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

=head1 NAME

LINE::Bot::API::Response::AudienceData

=head1 DESCRIPTION

This class correspond to the "Get audience data" response as described in
this page : L<https://developers.line.biz/en/reference/messaging-api/#response-25>

=cut

sub audienceGroupId     { $_[0]->{audienceGroupId} }
sub type                { $_[0]->{type} }
sub description         { $_[0]->{description} }
sub status              { $_[0]->{status} }
sub failedType          { $_[0]->{failedType} }
sub audienceCount       { $_[0]->{audienceCount} }
sub created             { $_[0]->{created} }
sub requestId           { $_[0]->{requestId} }
sub clickUrl            { $_[0]->{clickUrl} }
sub isIfaAudience       { $_[0]->{isIfaAudience} }
sub permission          { $_[0]->{permission} }
sub createRoute         { $_[0]->{createRoute} }
sub jobs                { $_[0]->{jobs} }

# Aliases
sub audience_group_id   { $_[0]->{audienceGroupId} }
sub failed_type         { $_[0]->{failedType} }
sub audience_count      { $_[0]->{audienceCount} }
sub request_id           { $_[0]->{requestId} }
sub click_url            { $_[0]->{clickUrl} }
sub is_ifa_audience       { $_[0]->{isIfaAudience} }
sub create_route         { $_[0]->{createRoute} }

1;

