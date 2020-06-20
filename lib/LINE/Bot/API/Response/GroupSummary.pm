package LINE::Bot::API::Response::GroupSummary;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

=head1 NAME

LINE::Bot::API::Response::GroupSummary

=head1 DESCRIPTION

This class correspond to below.
- "Get group summary" : See also L<https://developers.line.biz/en/reference/messaging-api/#get-group-id-response>
- "Get members in group count" : See also L<https://developers.line.biz/en/reference/messaging-api/#get-members-group-count>

=cut

sub groupId     { $_[0]->{groupId} }
sub groupName   { $_[0]->{groupName} }
sub pictureUrl  { $_[0]->{pictureUrl} }

sub count       { $_[0]->{count} }

# Aliases
sub group_id    { $_[0]->{groupId} }
sub group_name  { $_[0]->{groupName} }
sub picture_url { $_[0]->{pictureUrl} }

1;
