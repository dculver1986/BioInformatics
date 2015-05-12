use strict;
use warnings;
use feature qw(say);

my $string = 'ACGTACGTCGCGCGTTTTAAAATGC';
my @split_seq = split /(.)/, $string;
my $count = 0;

foreach my $letter ( @split_seq ) {
    if ( $letter =~ m/G|C/i ) {
            $count++;
        }
    }
say ' GC count decimal is ' . $count / length($string);
say ' GC count percentage is '. $count / length($string) * 100;
