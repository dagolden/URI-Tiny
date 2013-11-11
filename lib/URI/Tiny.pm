use v5.10;
use strict;
use warnings;

package URI::Tiny;
# ABSTRACT: small, simple, correct URI parsing and generation
# VERSION

my %RE = (
    parse_uri  => qr|^(?:([^:/?#]+):)?(?://([^/?#]*))?([^?#]*)(?:\?([^#]*))?(?:#(.*))?|,
    parse_auth => qr{^(?:([^\@]*)\@)?(\[[^\]]*\]|[^:]*)?(?::(.*))?},
);

sub parse {
    my ( $class, $arg ) = @_;
    return unless $arg =~ $RE{parse_uri};
    my $self = {
        scheme    => $1,
        authority => $2,
        path      => $3,
        query     => $4,
        fragment  => $5,
    };

    my ( $userinfo, $host, $port ) = $self->{authority} =~ $RE{parse_auth};
    $host =~ s/^\[(.*)\]$/$1/; # strip brackets on IP Literal host
    $self->{userinfo} = $userinfo;
    $self->{host}     = _unescape_all($host);
    $self->{port}     = $port;

    return bless $self, $class;

}

sub parts {
    my ($self) = @_;
    return {%$self};
}

sub params {
    my ($self) = @_;
    my %params;
    my @parts = split /[&;]/, $self->{query};
    for my $p (@parts) {
        my ( $key, $value ) = split /=/, $p, 2;
        return unless defined $value;
        $params{$key} = $value;
    }
    return \%params;
}

sub _unescape_all {
    my $str = shift;
    $str =~ s/%([0-9a-f]{2})/chr(hex($1))/ieg;
    return $str;
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

L<RFC 3986|http://tools.ietf.org/html/rfc3986>

=cut

# vim: ts=4 sts=4 sw=4 et:
