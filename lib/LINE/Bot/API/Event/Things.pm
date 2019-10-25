package LINE::Bot::API::Event::Things;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

use Carp 'carp';
our @CARP_NOT = qw( LINE::Bot::API::Event::Things LINE::Bot::API::Event LINE::Bot::API);

my %TYPE2CLASS = (
    link   => 'LINE::Bot::API::Event::Things::Link',
    unlink => 'LINE::Bot::API::Event::Things::Unlink',
    scenarioResult => 'LINE::Bot::API::Event::Things::ScenarioResult',
);

sub new {
    my($class, %args) = @_;

    my $type = $args{things}{type};
    my $things_class = $TYPE2CLASS{$type};
    unless ($things_class) {
        carp 'Unsupported Things type: ' . $type;
        $things_class = $class;
    }

    bless { %args }, $things_class;
}

sub is_things_event { 1 }

sub things_device_id { $_[0]->{things}{deviceId} }
sub things_type      { $_[0]->{things}{type} }

sub is_device_link   { 0 }
sub is_device_unlink { 0 }
sub is_scenario_result { 0 }

package LINE::Bot::API::Event::Things::Link {
    use parent 'LINE::Bot::API::Event::Things';

    sub is_device_link { 1 }
}

package LINE::Bot::API::Event::Things::Unlink {
    use parent 'LINE::Bot::API::Event::Things';

    sub is_device_unlink { 1 }
}

package LINE::Bot::API::Event::Things::ScenarioResult {
    use LINE::Bot::API::Event::Things::ActionResult;
    use parent 'LINE::Bot::API::Event::Things';

    sub is_scenario_result { 1 }

    sub scenario_id { $_[0]->{things}{result}{scenarioId} }

    sub start_time { $_[0]->{things}{result}{startTime} }

    sub end_time { $_[0]->{things}{result}{endTime} }

    sub result_code { $_[0]->{things}{result}{resultCode} }

    sub ble_notification_payload { $_[0]->{things}{result}{bleNotificationPayload} }

    sub action_results {
        my $self = shift;

        [ map {
                LINE::Bot::API::Event::Things::ActionResult->new(%$_);
            } @{$self->{things}{result}{actionResults}} ];
    }
}

1;
