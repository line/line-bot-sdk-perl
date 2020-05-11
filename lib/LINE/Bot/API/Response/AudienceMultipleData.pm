package LINE::Bot::API::Response::AudienceMultipleData;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

=head1 NAME

LINE::Bot::API::Response::AudienceMultipleData

=head1 DESCRIPTION

This class correspond to the "Get data for multiple audiences" response as described in
this page : L<https://developers.line.biz/en/reference/messaging-api/#response-26>

=cut

sub audienceGroups                          { $_[0]->{audienceGroups} }
sub hasNextPage                             { $_[0]->{hasNextPage} }
sub totalCount                              { $_[0]->{totalCount} }
sub readWriteAudienceGroupTotalCount        { $_[0]->{readWriteAudienceGroupTotalCount} }
sub page                                    { $_[0]->{page} }
sub size                                    { $_[0]->{size} }

# Aliases
sub audience_groups                         { $_[0]->{audienceGroups} }
sub has_next_page                           { $_[0]->{hasNextPage} }
sub total_count                             { $_[0]->{totalCount} }
sub read_write_audience_group_total_count   { $_[0]->{readWriteAudienceGroupTotalCount} }

1;

