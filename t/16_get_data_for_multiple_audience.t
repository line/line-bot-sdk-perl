use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use LINE::Bot::Audience;
use Furl;
use JSON::XS;

my $bot = LINE::Bot::Audience->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

subtest '#get_data_for_multiple_audience' => sub {
    subtest 'only required parameter' => sub {
        send_request {
            my $res = $bot->get_data_for_multiple_audience({
                page => 1
            });
            ok $res->is_success;
            is $res->http_status, 200;

            my @groups = $res->audience_groups;

            is $groups[0]->{audienceGroupId}, '123';
            is $groups[0]->{type}, 'UPLOAD';
            is $groups[0]->{description}, 'sample';
            is $groups[0]->{status}, 'READY';
            is $groups[0]->{audienceCount}, 100;
            is $groups[0]->{created}, 1587757389;
            ok $groups[0]->{isIfaAudience};
            is $groups[0]->{permission}, 'READ';
            is $groups[0]->{createRoute}, 'MESSAGING_API';

            is $res->totalCount, 1;
            is $res->readWriteAudienceGroupTotalCount, 0;
            is $res->page, 1;
            is $res->size, 1;

        } receive_request {
            my %args = @_;
            is $args{method}, 'GET';
            is $args{url}, 'https://api.line.me/v2/bot/audienceGroup/list?'
                . 'page=1'
                . '&description='
                . '&status='
                . '&size=20'
                . '&includesExternalPublicGroups='
                . '&createRoute=';

            +{
                audienceGroups => (
                    {
                        audienceGroupId => '123',
                        type => 'UPLOAD',
                        description => 'sample',
                        status => 'READY',
                        audienceCount => 100,
                        created => 1587757389,
                        isIfaAudience => JSON::XS::true,
                        permission => 'READ',
                        createRoute => 'MESSAGING_API',
                    },
                ),
                totalCount => 1,
                readWriteAudienceGroupTotalCount => 0,
                page => 1,
                size => 1,
            }
        };
    };

    subtest 'full parameter' => sub {
        send_request {
            my $res = $bot->get_data_for_multiple_audience({
                page => 1,
                description => 'sample',
                status => 'READY',
                size => 20,
                includesExternalPublicGroups => 'true',
                createRoute => 'MESSAGING_API',
            });
            ok $res->is_success;
            is $res->http_status, 200;

            my @groups = $res->audience_groups;

            is $groups[0]->{audienceGroupId}, '123';
            is $groups[0]->{type}, 'UPLOAD';
            is $groups[0]->{description}, 'sample';
            is $groups[0]->{status}, 'READY';
            is $groups[0]->{audienceCount}, 100;
            is $groups[0]->{created}, 1587757389;
            ok $groups[0]->{isIfaAudience};
            is $groups[0]->{permission}, 'READ';
            is $groups[0]->{createRoute}, 'MESSAGING_API';

            is $res->totalCount, 1;
            is $res->readWriteAudienceGroupTotalCount, 0;
            is $res->page, 1;
            is $res->size, 1;

        } receive_request {
            my %args = @_;
            is $args{method}, 'GET';
            is $args{url}, 'https://api.line.me/v2/bot/audienceGroup/list?'
                . 'page=1'
                . '&description=sample'
                . '&status=READY'
                . '&size=20'
                . '&includesExternalPublicGroups=true'
                . '&createRoute=MESSAGING_API';

            +{
                audienceGroups => (
                    {
                        audienceGroupId => '123',
                        type => 'UPLOAD',
                        description => 'sample',
                        status => 'READY',
                        audienceCount => 100,
                        created => 1587757389,
                        isIfaAudience => JSON::XS::true,
                        permission => 'READ',
                        createRoute => 'MESSAGING_API',
                    },
                ),
                totalCount => 1,
                readWriteAudienceGroupTotalCount => 0,
                page => 1,
                size => 1,
            }
        };
    };

};

done_testing();
