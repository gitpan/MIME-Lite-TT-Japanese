package MIME::Lite::TT::Japanese;

use strict;
use vars qw($VERSION);
$VERSION = '0.02';

use base qw(MIME::Lite::TT);
use Jcode;

sub _after_process {
	my $class = shift;
	my %options = (Type => 'text/plain; charset=iso-2022-jp',
				   Encoding => '7bit',
				   @_, );

	my $icode = delete $options{Icode};
	$icode ||= 'euc';
	$options{Subject} = Jcode->new($options{Subject}, $icode)->mime_encode;
	$options{Data} = Jcode->new($options{Data}, $icode)->jis;
	return %options;
}

1;
__END__

=head1 NAME

MIME::Lite::TT::Japanese - MIME::Lite::TT with Japanese character code

=head1 SYNOPSIS

  use MIME::Lite::TT::Japanese;

  my $msg = MIME::Lite::TT::Japanese->new(
              From => 'me@myhost.com',
              To => 'you@yourhost.com',
              Subject => 'Hi',
              Template => \$template,
              TmplParams => \%params, 
              TmplOptions => \%options,
              Icode => 'sjis',
            );

  $msg->send();

=head1 DESCRIPTION

MIME::Lite::TT::Japanese is subclass of MIME::Lite::TT.
This module helps creation of Japanese mail.

=head2 FEATURE

=over

=item *

'text/plain; charset=iso-2022-jp' is set to 'Type' of MIME::Lite option by the default.

=item *

'7bit' is set to 'Encoding' of MIME::Lite option by the default.

=item *

MIME encoding of the subject is carried out.

=item *

The character code of the mail text is converted to JIS.

=back

=head1 ADDITIONAL OPTIONS

=head2 Icode

The character code of the subject of mail and a template is set to this option.
'euc', 'sjis' or 'utf8' can be set.
If no values are set, it is assumed that it is 'euc'.

=head1 AUTHOR

Author E<lt>horiuchi@vcube.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<MIME::Lite::TT>

=cut
