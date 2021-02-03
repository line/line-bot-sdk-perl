package LINE::Bot::API::Response::NarrowcastStatus;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';


=head1 NAME

LINE::Bot::API::Response::NarrowcastStatus

=head1 DESCRIPTION

This class correspond to the "Get narrowcast message status" response as described in
this page : L<https://developers.line.biz/en/reference/messaging-api/#get-narrowcast-progress-status>

=cut

sub phase               { $_[0]->{phase} }
sub successCount        { $_[0]->{successCount} }
sub failureCount        { $_[0]->{failureCount} }
sub targetCount         { $_[0]->{targetCount} }
sub failedDescription   { $_[0]->{failedDescription} }
sub errorCode           { $_[0]->{errorCode} }
sub acceptedTime        { $_[0]->{acceptedTime} }
sub completedTime       { $_[0]->{completedTime} }

# Aliases
sub success_count       { $_[0]->{successCount} }
sub failure_count        { $_[0]->{failureCount} }
sub target_count         { $_[0]->{targetCount} }
sub failed_description   { $_[0]->{failedDescription} }
sub error_code           { $_[0]->{errorCode} }
sub accepted_time        { $_[0]->{acceptedTime} }
sub completed_time       { $_[0]->{completedTime} }

1;
