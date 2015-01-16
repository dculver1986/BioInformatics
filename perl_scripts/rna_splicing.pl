#! /usr/bin/perl

use strict;
use warnings;
use Carp qw(croak);
use MooseX::Params::Validate;

our %codons = (
    GCU => 'A',
    GCC => 'A',
    GCA => 'A',
    GCG => 'A',
    UGU => 'C',
    UGC => 'C',
    GAC => 'D',
    GAU => 'D',
    GAA => 'E',
    GAG => 'E',
    UUU => 'F',
    UUC => 'F',
    GGA => 'G',
    GGC => 'G',
    GGG => 'G',
    GGU => 'G',
    CAU => 'H',
    CAC => 'H',
    AUA => 'I',
    AUC => 'I',
    AUU => 'I',
    AAA => 'K',
    AAG => 'K',
    CUU => 'L',
    CUC => 'L',
    UUA => 'L',
    CUA => 'L',
    UUG => 'L',
    CUG => 'L',
    AUG => 'M',
    AAC => 'N',
    AAU => 'N',
    CCA => 'P',
    CCG => 'P',
    CCC => 'P',
    CCU => 'P',
    CAA => 'Q',
    CAG => 'Q',
    AGA => 'R',
    AGG => 'R',
    CGA => 'R',
    CGG => 'R',
    CGC => 'R',
    CGU => 'R',
    AGC => 'S',
    AGU => 'S',
    UCA => 'S',
    UCC => 'S',
    UCG => 'S',
    UCU => 'S',
    ACA => 'T',
    ACC => 'T',
    ACG => 'T',
    ACU => 'T',
    GUU => 'V',
    GUC => 'V',
    GUA => 'V',
    GUG => 'V',
    UGG => 'W',
    UAC => 'Y',
    UAU => 'Y',
    UAA => '',
    UAG => '',
    UGA => '',
);

# Parse file
my $file = 'ros_splice.txt';
my %parsed_fasta_file = parse_fasta($file);

# Translate DNA to RNA
my @translated_sequences;
for my $seq ( keys %parsed_fasta_file ) {
    $parsed_fasta_file{$seq} =~ s/T/U/ig;
    push @translated_sequences, $parsed_fasta_file{$seq};
}

# I want the longest string, the rest are the introns to check with
my @longest = sort { length($b) <=> length($a) } @translated_sequences;

# The first sequence is the string to check, the rest are introns
my $main_string = $longest[0];
my @introns = grep { $_ ne $main_string} @translated_sequences;

# parse the main string and excise with the provided introns/kmers
my @spliced_string;
for my $intron ( @introns ) {
    @spliced_string = parse_and_excise_introns(
        main_string => $main_string,
        kmer       => $intron,
    );
    $main_string = join '', @spliced_string; # rejoin the string after the splice
}

# join the final resulting spliced string
my $splice_result = join '', @spliced_string;

# Translate to protein, print the final result
print rna_to_protein($splice_result),"\n";

# Takes a path to fasta file and returns hash of header/sequence key-value pairs
sub parse_fasta {

    my $file = shift;

    open (my $fh, '<', $file) or die "Could not open file '$file' $!";

    my (%sequence_hash, $header);
    my @sequence;

    while ( my $line = <$fh> ) {
        chomp($line);
        if ( $line =~ m/^>(.*)/ ) {
            $header = $1;
        }
        else {
            $sequence_hash{$header} .= $line;
        }
    }

    return %sequence_hash;
}

# Takes an RNA string and returns a protein string
sub rna_to_protein {

    my $string = shift || croak "rna_to_protein caught invalid string";
    my $protein;

    while ( $string =~ s/^(\w{3})// ) {
        my $motif = $1;
        if ( $motif =~ m/UGA|UAG|UAA/ ) {
            $protein .= ""; # Stop codon, ignore and move on..
        }
        elsif ( length($motif) != 3 ) {
            croak "rna_to_protein caught invalid string: $motif";
        }
        elsif ( exists $codons{$motif} ) {
            $protein .= $codons{$motif};
        }
        else {
            croak "rna_to_protein caught invalid string: $motif";
        }

    }

    return $protein;
}

# This is a refactor of the frequent_words sub.
# Takes a main string to check and a kmer/intron string to check for removal
# Returns an array result of the main string with introns removed
sub parse_and_excise_introns {
    my (%args) = validated_hash(
        \@_,
        main_string => { isa => 'Str' },
        kmer        => { isa => 'Str' },
    );

    my $offset = 0;
    my $index;
    my $pattern;

    my @split_string = $args{main_string} =~ /(.)/g;

    for ( my $i = 0 ; $i < scalar(@split_string); $i++ ) {
        $pattern = substr( $args{main_string}, $i, length($args{kmer}) );
        $index = index($args{main_string}, $args{kmer}, $offset);
        if ( $pattern eq $args{kmer} ) {
                #print "found $args{kmer} at $index\n"; # leave for debugging
            splice @split_string, $index, length($pattern);
        }
    }
    return @split_string;
}

