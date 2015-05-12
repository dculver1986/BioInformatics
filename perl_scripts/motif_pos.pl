use strict;
use warnings;

use Data::Dumper;


print occurrences('ATAT','GATATATGCATATACTT'),"\n";

sub occurrences {

    my( $x, $y ) = @_;

    my $pos = 0;
    my $matches = 0;

    while (1) {
        $pos = index($y, $x, $pos);
        last if($pos < 0);
        $matches++;
        $pos++;
        print "found at ". $pos ."\n";
    }

    return $matches;
}

=ignore

# Algorithm for pattern count:

PatternCount(Text, Pattern)
        count ← 0
        for i ← 0 to |Text| − |Pattern|
            if Text(i, |Pattern|) = Pattern
                count ← count + 1
        return count

=cut

sub pattern_count {
    my ($text, $pattern) = @_;

    my $pat_len = length($pattern);
    my $count = 0;
    my $pos;
    for ( my $i = 0; $i < length($text); $i++) {
        if ( $pattern eq substr($text, $i, $pat_len ) ) {
            $count += 1;
            $pos = $i + 1;
            print "found $pattern at $pos\n";
        }
    }
    return $count;

}

print "PATTERN_COUNT: ". pattern_count('GATATATGCATATACTT', 'ATAT'),"\n";

