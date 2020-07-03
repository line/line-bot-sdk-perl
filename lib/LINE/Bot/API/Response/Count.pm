package LINE::Bot::API::Response::Count;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

=head1 NAME
LINE::Bot::API::Response::Count

=head1 DESCRIPTION

This class correspond to below.
- "Get members in group count" : See also L<https://developers.line.biz/en/reference/messaging-api/#get-members-group-count>
- "Get members in room count" : See also L<https://developers.line.biz/en/reference/messaging-api/#get-members-room-count>

=cut

sub count  { $_[0]->{count} }

1;
