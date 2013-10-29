use 5.008001;
use strict;
use warnings;
use Test::More 0.96;
use Test::FailWarnings;
use Test::Deep qw/!blessed/;
use Test::Fatal;
binmode( Test::More->builder->$_, ":utf8" )
  for qw/output failure_output todo_output/;

use URI::Tiny;

my %eg = (
    'http absolute' => {
        uri   => 'http://a/b/c/d;p?q#z',
        parse => {
            scheme    => 'http',
            authority => 'a',
            path      => '/b/c/d;p',
            query     => 'q',
            fragment  => 'z',
        }
    },
    'file local' => {
        uri   => 'file:///a/b/c',
        parse => {
            scheme    => 'file',
            authority => '',
            path      => '/a/b/c',
            query     => undef,
            fragment  => undef,
        },
    },
);

for my $c ( sort keys %eg ) {
    subtest "parse $c" => sub {
        ok( my $uri = URI::Tiny->parse( $eg{$c}{uri} ), "parse uri" );
        cmp_deeply( $uri->parts, $eg{$c}{parse}, "parse correct" );
    };
}

done_testing;

# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
