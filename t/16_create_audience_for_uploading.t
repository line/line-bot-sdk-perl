use strict;
use warnings;
use Test2::V0;
use lib 't/lib';
use t::Util;

use LINE::Bot::Audience;
use Furl;
use JSON::XS;

my $bot = LINE::Bot::Audience->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

subtest '#create_audience_for_uploading' => sub {
    subtest 'only required paraemter' => sub {
        send_request {
            my $res = $bot->create_audience_for_uploading({
                description => 'sample text',
                isIfaAudience => JSON::XS::false,
            });
            ok $res->is_success;
            is $res->http_status, 200;
        } receive_request {
            my %args = @_;
            is $args{method}, 'POST';
            is $args{url}, 'https://api.line.me/v2/bot/audienceGroup/upload';

            my %headers = @{ $args{headers} };
            is $headers{'Content-Type'}, 'application/json';

            my $content = decode_json($args{content} // '');
            is $content->{description}, 'sample text';
            ok !$content->{isIfaAudience};

            +{}
        };
    };

    subtest 'full parameter' => sub {
        send_request {
            my $res = $bot->create_audience_for_uploading({
                description => 'sample text',
                isIfaAudience => JSON::XS::true,
                uploadDescription => 'sample text',
                audiences => [
                    {
                        id => 123,
                    },
                    {
                        id => 124,
                    },
                ],
            });
            ok $res->is_success;
            is $res->http_status, 200;
        } receive_request {
            my %args = @_;
            is $args{method}, 'POST';
            is $args{url}, 'https://api.line.me/v2/bot/audienceGroup/upload';

            my %headers = @{ $args{headers} };
            is $headers{'Content-Type'}, 'application/json';

            my $content = decode_json($args{content} // '');
            is $content->{description}, 'sample text';
            ok $content->{isIfaAudience};
            is $content->{uploadDescription}, 'sample text';
            is @{ $content->{audiences} }, 2;
            is $content->{audiences}->[0]->{id}, 123;
            is $content->{audiences}->[1]->{id}, 124;

            +{}
        };
    };
};

subtest '#create_audience_for_uploading_by_file' => sub {
    my $file_path = 't/examples/create_audience_for_uploading_by_file';

    subtest 'only required paraemter' => sub {
        send_request {
            my $res = $bot->create_audience_for_uploading_by_file({
                description => 'sample text',
                file => $file_path,
            });
            ok $res->is_success;
            is $res->http_status, 200;

            is $res->audienceGroupId, 4389303728991;
            is $res->audience_group_id, 4389303728991, 'alias check';
            is $res->type, 'UPLOAD';
            is $res->description, 'test';
            is $res->created, 1500351844;
        } receive_request {
            my %args = @_;
            is $args{method}, 'POST';
            is $args{url}, 'https://api-data.line.me/v2/bot/audienceGroup/upload/byFile';

            my %headers = @{ $args{headers} };
            is $headers{'Content-Type'}, 'multipart/form-data';

            my %content = @{ $args{content} };
            is $content{description}, 'sample text';
            ok $content{file};

            # this example response is from 'https://developers.line.biz/en/reference/messaging-api/#create-upload-audience-group-by-file-response'
            +{
                audienceGroupId => 4389303728991,
                type => 'UPLOAD',
                description => 'test',
                created => 1500351844,
            }
        };
    };

    subtest 'full parameter' => sub {
        send_request {
            my $res = $bot->create_audience_for_uploading_by_file({
                description => 'sample text',
                isIfaAudience => JSON::XS::true,
                uploadDescription => 'sample text',
                file => $file_path,
            });
            ok $res->is_success;
            is $res->http_status, 200;

            is $res->audienceGroupId, 4389303728991;
            is $res->audience_group_id, 4389303728991, 'alias check';
            is $res->type, 'UPLOAD';
            is $res->description, 'test';
            is $res->created, 1500351844;
        } receive_request {
            my %args = @_;
            is $args{method}, 'POST';
            is $args{url}, 'https://api-data.line.me/v2/bot/audienceGroup/upload/byFile';

            my %headers = @{ $args{headers} };
            is $headers{'Content-Type'}, 'multipart/form-data';

            my %content = @{ $args{content} };
            is $content{description}, 'sample text';
            ok $content{isIfaAudience};
            is $content{uploadDescription}, 'sample text';
            ok $content{file};

            # this example response is from 'https://developers.line.biz/en/reference/messaging-api/#create-upload-audience-group-by-file-response'
            +{
                audienceGroupId => 4389303728991,
                type => 'UPLOAD',
                description => 'test',
                created => 1500351844,
            }
        };
    };
};

done_testing();
