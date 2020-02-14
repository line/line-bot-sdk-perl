package LINE::Bot::API::Response::FriendDemographics;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub available           { $_[0]->{available} }
sub genders             { $_[0]->{genders} }
sub ages                { $_[0]->{ages} }
sub areas               { $_[0]->{areas} }
sub appTypes            { $_[0]->{appTypes} }
sub subscriptionPeriods { $_[0]->{subscriptionPeriods} }

1;
