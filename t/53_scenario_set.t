use strict;
use warnings;
use Test::More;
use lib 't/lib';
use t::Util;

use JSON::XS qw(decode_json);
use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

subtest register_scenario_set => sub {
    # example taken from https://developers.line.biz/en/reference/line-things/#create-scenario-set
    my $scenario_set = decode_json(<<'JSON');
    {
      "autoClose": false,
      "suppressionInterval": 0,
      "scenarios": [
	{
	  "trigger": {
	    "type": "BLE_NOTIFICATION",
	    "serviceUuid": "4812a0a6-10af-4afb-91f0-b4434e55763b",
	    "characteristicUuid": "91a6fb1d-d365-4229-9d41-4358a96388e3"
	  },
	  "actions": [
	    {
	      "type": "SLEEP",
	      "sleepMillis": 1000
	    },
	    {
	      "type": "GATT_READ",
	      "serviceUuid": "4812a0a6-10af-4afb-91f0-b4434e55763b",
	      "characteristicUuid": "91a6fb1d-d365-4229-9d41-4358a96388e3"
	    },
	    {
	      "type": "GATT_WRITE",
	      "serviceUuid": "4812a0a6-10af-4afb-91f0-b4434e55763b",
	      "characteristicUuid": "91a6fb1d-d365-4229-9d41-4358a96388e3",
	      "data": "Zm9vCg=="
	    }
	  ]
	}
      ]
    }
JSON
    $scenario_set->{autoClose} = $scenario_set->{autoClose} + 0; # hack: needed since the type checker rejects JSON::PP::Boolean

    my $product_id = 1;

    send_request {
        my $res = $bot->register_scenario_set({
            product_id => $product_id,
            scenario_set => $scenario_set,
        });
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'PUT';
        is $args{url},    "https://api.line.me/things/v1/products/$product_id/scenario-set",

        my $has_header = 0;
        my @headers = @{ $args{headers} };
        while (my($key, $value) = splice @headers, 0, 2) {
            $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
        }
        is $has_header, 1;

        return +{};
    };
};

done_testing;
