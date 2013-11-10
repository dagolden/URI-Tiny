package TestBridge;

use strict;
use warnings;

use Test::More 0.99;
use TestUtils;
use TestML::Tiny;

binmode(Test::More->builder->$_, ":utf8")
    for qw/output failure_output todo_output/;

use Exporter   ();
our @ISA    = qw{ Exporter };
our @EXPORT = qw{
    test_parse
    test_params
    run_all_testml_files
    run_testml_file
    run_tml_t_file
};

use File::Basename;
use URI::Tiny;
use CPAN::Meta::YAML;

#--------------------------------------------------------------------------#
# run_all_testml_files
#
# Iterate over all .tml files in a directory using a particular test bridge
# code # reference.  Each file is wrapped in a subtest with a test plan
# equal to the number of blocks.
#--------------------------------------------------------------------------#

sub run_all_testml_files {
    my ($label, $dir, $bridge, @args) = @_;

    my $code = sub {
        my ($file, $blocks) = @_;
        subtest "$label: $file" => sub {
            plan tests => scalar @$blocks;
            $bridge->($_, @args) for @$blocks;
        };
    };

    my @files = find_tml_files($dir);

    run_testml_file($_, $code) for sort @files;
}

#--------------------------------------------------------------------------#
# run_testml_file
#
# Run a single file with a callback that iterates over blocks in a file
#--------------------------------------------------------------------------#

sub run_testml_file {
    my ($file, $code) = @_;

    my $blocks = TestML::Tiny->new(
        testml => $file,
        version => '0.1.0',
    )->{function}{data};

    $code->($file, $blocks);
}

#--------------------------------------------------------------------------#
# _testml_has_points
#
# Extract test points from a test block
#--------------------------------------------------------------------------#

sub _testml_has_points {
    my ($block, @points) = @_;
    my @values;
    for my $point (@points) {
        defined $block->{$point} or return;
        push @values, $block->{$point};
    }
    push @values, $block->{Label};
    return @values;
}


#--------------------------------------------------------------------------#
# run_tml_t_file
#
# Run a .tml file based on a .t file
#--------------------------------------------------------------------------#

sub run_tml_t_file {
    my ($label) = @_;

    my $file = basename $0;
    $file =~ s/(.*)\.t$/$1.tml/;
    my $method = "test_$1";
    my $bridge = __PACKAGE__->can($method)
        or die "Can't find bridge for $label: $method";

    my $code = sub {
        my ($file, $blocks) = @_;
        $bridge->($_) for @$blocks;
    };

    run_testml_file("t/testml/$file", $code);
}

#--------------------------------------------------------------------------#
# test_parse
#
# two blocks: uri, yaml
#--------------------------------------------------------------------------#

sub test_parse {
    my ($block) = @_;

    my ($uri, $yaml, $label) =
      _testml_has_points($block, qw(uri yaml)) or return;

    chomp($uri);
    my $expected = CPAN::Meta::YAML->read_string($yaml)->[0];

    subtest "$label: $uri" => sub {
        ok( my $got = eval { URI::Tiny->parse($uri) }, "parsed without error" )
            or diag $@;
        is_deeply( $got->parts, $expected, "parse correct" );
    };
}

#--------------------------------------------------------------------------#
# test_params
#
# two blocks: uri, yaml
#--------------------------------------------------------------------------#

sub test_params {
    my ($block) = @_;

    my ($uri, $yaml, $label) =
      _testml_has_points($block, qw(uri yaml)) or return;

    chomp($uri);
    my $obj = CPAN::Meta::YAML->read_string($yaml);
    my $expected = $obj->[0];

    subtest "$label: $uri" => sub {
        ok( my $got = eval { URI::Tiny->parse($uri) }, "parsed without error" )
            or diag $@;
        my $params = $got->params;
        if ( defined $expected ) {
            is_deeply( $params, $expected, "params correct" );
        }
        else {
            is( $params, undef, "no valid params in the URI" );
        }
    };
}

1;
