package LINE::Bot::API::Response::AudienceGroupForUploadingUserId;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

=head1 NAME

LINE::Bot::API::Response::AudienceGroupForUploadingUserId

=head1 DESCRIPTION

This class correspond to the "Create audiece for uploading user IDs" response as described in
this page : L<https://developers.line.biz/en/reference/messaging-api/#response-16>

=cut

sub audienceGroupId     { $_[0]->{audienceGroupId} }
sub type                { $_[0]->{type} }
sub description         { $_[0]->{description} }
sub created             { $_[0]->{created} }

# Aliases
sub audience_group_id   { $_[0]->{audienceGroupId} }

1;

