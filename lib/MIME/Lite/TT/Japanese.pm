package MIME::Lite::TT::Japanese;

use strict;
use vars qw($VERSION);
$VERSION = '0.05';

use base qw(MIME::Lite::TT);
use Jcode;
use Mail::Date;

BEGIN {
	if ( $] >= 5.008 ) {
		require Encode;
		require Encode::Guess;
	}
}

my ($encode, $guess_encoding);
BEGIN {
	if ( $] >= 5.008 ) {
		no strict 'subs';
 		$encode = sub {
 			my ($str, $ocode, $icode) = @_;
 			$icode ||= $guess_encoding->($str);
 			$icode = 'euc-jp' if $icode eq 'euc';
 			$ocode = 'euc-jp' if $ocode eq 'euc';
			Encode::from_to($str, $icode, $ocode ,Encode::FB_QUIET);
			return $str;
 		};
		$guess_encoding = sub {
			my $enc = Encode::Guess::guess_encoding(shift, qw/euc-jp shiftjis 7bit-jis/);
			return ref($enc) ? $enc->name : 'euc-jp';
		};
 	} else {
 		$encode = sub {
 			my ($str, $ocode, $icode) = @_;
 			return Jcode->new($str, $icode || $guess_encoding->($str) )->$ocode
 		};
		$guess_encoding = sub {
			my ($str) = @_;
			my $enc = Jcode::getcode($str) || 'euc';
			$enc = 'euc' if $enc eq 'ascii' || $enc eq 'binary';
			return $enc;
		};
	}
}

sub _after_process {
	my $class = shift;
	my %options = (Type => 'text/plain; charset=iso-2022-jp',
				   Encoding => '7bit',
                   Datestamp => 0,
                   Date => datetime_rfc2822(time, '+0900'),
				   @_, );
	$options{Subject} = mime_encode( $encode->($options{Subject}, 'euc', $options{Icode}) );
	$options{Data} = $encode->( $options{Data}, 'jis', $options{Icode} );
	return %options;
}

sub mime_encode { Jcode->new(shift, 'euc')->mime_encode }

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

'text/plain; charset=iso-2022-jp' is set to 'Type' of MIME::Lite option by default.

=item *

'7bit' is set to 'Encoding' of MIME::Lite option by default.

=item *

convert the subject to MIME-Header documented in RFC1522.

=item *

convert the mail text to JIS.

=item *

set Japanese local-time at Date field by default.

=back

=head1 ADDITIONAL OPTIONS

=head2 Icode

Set the character code of the subject and the template.
'euc', 'sjis' or 'utf8' can be set.
If no value is set, this module try to guess encoding.
If it is failed to guess encoding, 'euc' is assumed.

=head1 AUTHOR

Author E<lt>horiuchi@vcube.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<MIME::Lite::TT>

=cut
