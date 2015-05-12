#! /usr/bin/perl

use strict;
use warnings;

use List::Util qw(min);
use Data::Dumper;


my $file = '/home/dculver/perl_scripts/skew.txt';
my $string = do {
    local $/ = undef;
    open ( my $fh, '<', $file ) or die "could not open file: $!";
    <$fh>;
};

## Get Skew Values of $genome

my $genome       = 'TAAAGACTGCCGAGAGGCCAACACGAGTGCTAGAACGAGGGGCGTAAACGCGGGTCCGAT';
my @split_genome = split m//m, $genome;


#my @split_genome = split m//m, $string;

my $count = 0;
my $index = 0;

my $skew_ref;
push @{$skew_ref}, { $count => $index };# because the 0-th skew value always is 0

foreach my $nucleotide ( @split_genome ) {
    $index += 1;
    if ( $nucleotide eq 'G' ) {
        $count += 1;
        push @{$skew_ref}, { $count => $index };
    }
    elsif ( $nucleotide eq 'C' ) {
        $count -= 1;
        push @{$skew_ref}, { $count => $index };
    }
    else {
        push @{$skew_ref}, { $count => $index };
        next;
    }
}

my @sorted = map $_->[0],
  sort { $a->[1] <=> $b->[1] }
  map [ $_, keys %$_ ], @{$skew_ref};


for my $ref ( @{$skew_ref} ) {
    while ( my ($k, $v ) = each %{$ref} ) {
        print "$k => $v\n";
    }
}


print Dumper(\@sorted);
