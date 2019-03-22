#!/usr/bin/env perl
use strict;



use FindBin '$Bin';
use File::Spec;
use JSON::XS qw(decode_json);
use Test::More;

use LINE::Bot::API::Types qw<MessageEvent>;

sub verify {
    my ($type, $file) = @_;

    $file = File::Spec->join($Bin, 'examples', $file);
    print "== $file\n";

    open my $fh, '<', $file;
    my $c = do { local $/; <$fh> };
    close($fh);

    my $val = decode_json($c);

    my $error = $type->validate($val);
    if ($error) {
        fail "$type: $file";
        diag $error;
    } else {
        pass "$type: $file";
    }
}

my @tests = (
    [ MessageEvent, 'text-message-1.json'],
);

for (@tests){
    verify(@$_);
}
done_testing;
