use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'MIME::Lite::TT::Japanese' }

my $body = '';

my $msg = MIME::Lite::TT::Japanese->new(
    From      => '���� ��� <tanaka@example.com>',
    Subject   => '�Ƥ��Ȥ᡼��',
    Template  => \$body,
    Icode     => 'euc',
    LineWidth => 0,
);
is $msg->get('From'), '=?ISO-2022-JP?B?GyRCRURDZhsoQiAbJEI3cjJwGyhC?= <tanaka@example.com>', 'From';
is $msg->get('Subject'), '=?ISO-2022-JP?B?GyRCJEYkOSRIJGEhPCRrGyhC?=','Subject';
