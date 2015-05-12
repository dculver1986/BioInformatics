#! /usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

# Takes file/string and length and returns an Array Ref of patterns
# that occur most frequently of the given length

my $file   = '/home/dculver/perl_scripts/freq.txt';
my $string = do {
    local $/ = undef;
    open( my $fh, '<', $file ) or die "could not open file: $!";
    <$fh>;
};

my $frequent = frequent_words( $string, 14 );

print "$_\n" for @{$frequent};

sub frequent_words {
    my ( $text, $kmer ) = @_;
    my @split_string = $text =~ /(.)/g;
    my @frequent_patterns;
    my $pattern;
    my %hash;

    for ( my $i = 0 ; $i < scalar(@split_string) ; $i++ ) {
        $pattern = substr( $text, $i, $kmer );
        if ( length($pattern) == $kmer ) {
            push @frequent_patterns, $pattern;
            $hash{$pattern}++;
        }
    }

    my @sorted_values = sort { $hash{$b} <=> $hash{$a} } keys %hash;
    my @frequent_kmers;
    for my $string (@sorted_values) {
        if ( $hash{$string} == $hash{ $sorted_values[0] } ) { # Get largest value
            push @frequent_kmers, $string;
        }
    }

    return \@frequent_kmers;

}

=ignore
# pseudocode from BioInformatics Alg class
FrequentWords(Text, k)
        FrequentPatterns ← an empty set
        for i ← 0 to |Text| − k
            Pattern ← the k-mer Text(i, k)
            Count(i) ← PatternCount(Text, Pattern)
        maxCount ← maximum value in array Count
        for i ← 0 to |Text| − k
            if Count(i) = maxCount
                add Text(i, k) to FrequentPatterns
        return FrequentPatterns
=cut

