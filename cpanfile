requires 'perl', '5.014000';

requires 'parent';
requires 'Digest::SHA';
requires 'Furl';
requires 'JSON::XS';
requires 'IO::Socket::SSL';
requires 'MIME::Base64';
requires 'Type::Tiny', '1.004000';
requires 'URI';
requires 'URI::QueryParam';

on test => sub {
    requires 'Test::More';
};
