#!/bin/perl
use strict;

#
# Hacky process of CSV (if ever quoted values etc then use Text::CSV or similar)
# Adds an extra column representing a mythical car being the target car one lap down
#

sub addLap {
    my ($tgtcol,$lines) = @_;
    my $tgtlabel = "";
    my @colTimes;
    foreach (@$lines)
    {
        if (/^lap,/)
        {
            chomp;
            $tgtlabel = (split(","))[$tgtcol];
            $_ = $_ . ",${tgtlabel}+1\n";
            print STDERR "Lapchart for $tgtlabel\n";
        }
        next unless /^\d+,/;
        my @times = split(",");
        push(@colTimes, $times[$tgtcol]);
    }

    shift(@colTimes);

    foreach (@$lines)
    {
        next unless /^\d+,/;
        chomp;
        $_ = $_ . "," . (shift(@colTimes) || "") . "\n";
    }
    return @$lines;
}

my $tgtcol = $ARGV[0] =~ /^\d+$/ ? shift : 4;
print(join("", addLap($tgtcol, [<>])), "\n");
