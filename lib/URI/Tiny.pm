use v5.10;
use strict;
use warnings;

package URI::Tiny;
# ABSTRACT: small, simple, correct URI parsing and generation
# VERSION

my %RE =
  ( parse_uri => qr|^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?|, );

sub parse {
    my ( $class, $arg ) = @_;
    return unless $arg =~ $RE{parse_uri};
    my $self = {
        scheme    => $2,
        authority => $4,
        path      => $5,
        query     => $7,
        fragment  => $9,
    };
    return bless $self, $class;
}

sub parts {
    my ($self) = @_;
    return {%$self};
}

1;

=for Pod::Coverage BUILD

=head1 SYNOPSIS

    use URI::Tiny;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

=for :list
* Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
