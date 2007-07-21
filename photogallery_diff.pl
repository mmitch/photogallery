#!/usr/bin/perl
# $Id: photogallery_diff.pl,v 1.2 2007-07-21 13:25:11 mitch Exp $
#
# list changes within photogallery.sh directory structure
#
# 2007 (c) by Christian Garbs <mitch@cgarbs.de>
#

use strict;
use warnings;

# variables
my $DATADIR    = '~/photogallery';
my $GALLERYDIR = '/mnt/bilder/Fotos';
my $MAXCHANGES = 20;

# expand ~
$DATADIR    =~ s/^~/$ENV{HOME}/;
$GALLERYDIR =~ s/^~/$ENV{HOME}/;

# scan structure
# get new counts
my %count_new;

open FIND, "find $GALLERYDIR -type f -name index.html|" or die "can't spawn find: $!";
while (my $index = <FIND>) {
    chomp $index;

    open INDEX, '<', $index or die "can't read `$index': $!";
    my $new = { 'SUBDIRS' => 0 };
    while (my $line = <INDEX>) {
	if ($line =~ /^PICTURES=(\d+)$/) {
	    $new->{'PICTURES'} = $1;
	} elsif ($line =~ /^SUBDIRS=(\d+)$/) {
	    $new->{'SUBDIRS'} = $1;
	} elsif ($line =~ /^DATE=(\d+)$/) {
	    $new->{'DATE'} = $1;
	}
    }
    close INDEX or die "can't close `$index': $!";
    $count_new{$index} = $new if exists $new->{'PICTURES'};
}
close FIND or die "can't close find: $!";

# get old counts
my %count_old;
my $oldstats = "$DATADIR/last_run";

open OLDSTATS, '<', $oldstats or die "can't open `$oldstats': $!";
while (my $line = <OLDSTATS>) {
    chomp $line;
    if ($line =~ /^(\d+)\t(.+)$/) {
	$count_old{$2}->{'PICTURES'} = $1;
    }
}
close OLDSTATS or die "can't close `$oldstats': $!";

# get old diffs
my @diff;
my $olddiffs = "$DATADIR/last_diffs";

open OLDDIFFS, '<', $olddiffs or die "can't open `$olddiffs': $!";
while (my $line = <OLDDIFFS>) {
    chomp $line;
    if ($line =~ /^(\d+)\t(\d+)\t(\d+)\t(.+)$/) {
	push @diff, $line;
    }
}
close OLDDIFFS or die "can't close `$olddiffs': $!";


# generate diffs
my %count_change;
#   add
foreach my $dir (sort keys %count_new) {
    my ($old, $new) = ($count_old{$dir}, $count_new{$dir});
    if (defined $old) {
	if ($old->{'PICTURES'} != $new->{'PICTURES'}) {
	    $count_change{$dir} = { 'OLD' => $old, 'NEW' => $new };
	}
    } else {
	$count_change{$dir} = { 'OLD' => { 'PICTURES' => 0 }, 'NEW' => $new };
    }
}
#   remove
foreach my $dir (sort keys %count_old) {
    my ($old, $new) = ($count_old{$dir}, $count_new{$dir});
    if (defined $new) {
	if ($old->{'PICTURES'} != $new->{'PICTURES'}) {
	    $count_change{$dir} = { 'OLD' => $old, 'NEW' => $new };
	}
    } else {
	$count_change{$dir} = { 'OLD' => $old, 'NEW' => { 'PICTURES' => 0 } };
    }
}

# print diffs
my $timestamp = `date +%Y%m%d%H%M%S`;
chomp $timestamp;
foreach my $dir (reverse sort keys %count_change) {
    push @diff, sprintf "%d\t%d\t%s\t%s",
    $count_change{$dir}->{'OLD'}->{'PICTURES'},
    $count_change{$dir}->{'NEW'}->{'PICTURES'},
    $timestamp,
#    exists $count_change{$dir}->{'NEW'}->{'DATE'} ? $count_change{$dir}->{'NEW'}->{'DATE'} : $timestamp,
    $dir;
}

# chop diffs
if (scalar @diff > $MAXCHANGES) {
    splice(@diff, 0, -$MAXCHANGES);
}

### TODO below here

# print new diffs
my $newdiffs = "$DATADIR/last_diffs.new";
open NEWDIFFS, '>', $newdiffs or die "can't open `$newdiffs': $!";
foreach my $diff (@diff) {
    print NEWDIFFS "$diff\n";
}
close NEWDIFFS or die "can't close `$newdiffs': $!";

# print new status
my $newstats = "$DATADIR/last_run.new";
open NEWSTATS, '>', $newstats or die "can't open `$newstats': $!";
foreach my $dir (sort keys %count_new) {
    printf NEWSTATS "%d\t%s\n",
    $count_new{$dir},
    $dir;
}
close NEWSTATS or die "can't close `$newstats': $!";

# rename
my $bakdiffs = "$DATADIR/last_diffs.bak";
my $bakstats = "$DATADIR/last_run.bak";

my @moves = (
	     $olddiffs, $bakdiffs,
	     $oldstats, $bakstats,
	     $newdiffs, $olddiffs,
	     $newstats, $oldstats
	     );

while (@moves) {
    my ($from, $to) = splice(@moves, 0, 2);
    rename $from, $to or die "can't rename `$from' to `$to': $!";
}
