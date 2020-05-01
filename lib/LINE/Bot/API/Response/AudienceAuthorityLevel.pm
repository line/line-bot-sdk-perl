package LINE::Bot::API::Response::AudienceAuthorityLevel;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

=head1 NAME

LINE::Bot::API::Response::AudienceAuthorityLevel

=head1 DESCRIPTION

This class correspond to the "Get the authority level of the audience" response as described in
this page : L<https://developers.line.biz/en/reference/messaging-api/#response-27>

=cut

sub authorityLevel     { $_[0]->{authorityLevel} }

# Aliases
sub authority_level   { $_[0]->{authorityLevel} }

1;

