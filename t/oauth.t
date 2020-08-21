use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use JSON::XS qw(decode_json);
use URI::Escape;

use LINE::Bot::API;


my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

subtest 'issue channel access token (successful case)', sub {
    send_request {
        my $res = $bot->issue_channel_access_token({
            client_id => 'DUMMY_CLIENT_ID',
            client_secret => $bot->{channel_secret},
        });

        ok $res->is_success;
        is $res->http_status, 200;

        is $res->access_token, 'NEWTOKEN';
        is $res->expires_in,   '2592000';
        is $res->token_type,   'Bearer';
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/oauth/accessToken';

        return +{
            access_token => 'NEWTOKEN',
            expires_in   => 2592000,
            token_type   => 'Bearer',
        };
    };
};

subtest 'renew access token (successful case)', sub {
    send_request {
        my $res = $bot->revoke_channel_access_token({
            access_token => 'TOBEDELETEDTOKEN'
        });

        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/oauth/revoke';

        return +{}
    };
};

subtest 'renew access token (error case)', sub {
    send_request {
        my $res = $bot->revoke_channel_access_token({
            access_token => 'INVALIDTOKEN'
        });

        ok ! $res->is_success;
        isnt $res->http_status, 200;
        ok $res->error;
        ok $res->error_description;
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/oauth/revoke';

        return +{
            http_status => 400,
            error => "ERR",
            error_description => "ERRRR",
        }
    };
};

subtest 'issue channel access token v2.1 (successful case)' => sub {
    send_request {
        my $res = $bot->issue_channel_access_token_v2_1({ jwt => 'DUMMY_JWT' });

        ok $res->is_success;
        is $res->http_status, 200;

        is $res->access_token,  'NEWTOKEN';
        is $res->expires_in,    '2592000';
        is $res->token_type,    'Bearer';
        is $res->key_id,        'dummy_key_id'
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/oauth2/v2.1/token';

        my @contents = @{$args{content} // ''};
        my $has_header = 0;
        while (my($key, $value) = splice @contents, 0, 2) {
            $has_header++ if $key eq 'grant_type' && $value eq 'client_credentials';
            $has_header++ if $key eq 'client_assertion_type' && $value eq 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer';
            $has_header++ if $key eq 'client_assertion' && $value eq 'DUMMY_JWT';
        }
        is $has_header, 3;

        return +{
            access_token    => 'NEWTOKEN',
            expires_in      => 2592000,
            token_type      => 'Bearer',
            key_id          => 'dummy_key_id',
        };
    };
};

subtest 'get valid channel access token v2.1' => sub {

    my $dummy_result = [
        "U_gdnFYKTWRxxxxDVZexGg",
        "sDTOzw5wIfWxxxxzcmeQA",
        "73hDyp3PxGfxxxxD6U5qYA",
        "FHGanaP79smDxxxxyPrVw",
        "CguB-0kxxxxdSM3A5Q_UtQ",
        "G82YP96jhHwyKSxxxx7IFA"
    ];

    send_request {
        my $res = $bot->get_valid_channel_access_token_v2_1({ jwt => 'DUMMY_JWT' });

        ok $res->is_success;
        is $res->http_status, 200;

        is_deeply($res->key_ids, $dummy_result);

    } receive_request {
        my %args = @_;
        is $args{method}, 'GET';

        my $jwt = uri_escape('DUMMY_JWT');
        my $assertion_type = uri_escape('urn:ietf:params:oauth:client-assertion-type:jwt-bearer');
        is $args{url},    'https://api.line.me/oauth2/v2.1/tokens/kid' . "?client_assertion_type=$assertion_type&client_assertion=$jwt";

        return +{
            key_ids => [
                "U_gdnFYKTWRxxxxDVZexGg",
                "sDTOzw5wIfWxxxxzcmeQA",
                "73hDyp3PxGfxxxxD6U5qYA",
                "FHGanaP79smDxxxxyPrVw",
                "CguB-0kxxxxdSM3A5Q_UtQ",
                "G82YP96jhHwyKSxxxx7IFA"
            ]
        };
    };
};

done_testing;
