#!/usr/bin/perl
# $Id: photogallery_diff2html.pl,v 1.4 2007-07-21 13:53:59 mitch Exp $
#
# converts photogallery.sh changes to HTML page
#
# 2007 (c) by Christian Garbs <mitch@cgarbs.de>
#

use strict;
use warnings;

# variables
my $DATADIR    = '~/photogallery';
my $DIRPREFIX  = '/mnt/bilder/Fotos';
my $WEBPREFIX  = 'http://www.mitch.h.shuttle.de/fotos';
my $RSSURL     = '';
my $CHARSET    = 'UTF-8';
my $DATELANG   = 'C';

# expand ~
$DATADIR =~ s/^~/$ENV{HOME}/;

# get old diffs
my @diff;
my $diffs = "$DATADIR/last_diffs";

open DIFFS, '<', $diffs or die "can't open `$diffs': $!";
while (my $line = <DIFFS>) {
    chomp $line;
    if ($line =~ /^(\d+)\t(\d+)\t(\d+)\t(.+)$/) {
	push @diff, {
	    'OLD' => $1,
	    'NEW' => $2,
	    'DATE' => $3,
	    'PATH' => $4
	};
    }
}
close DIFFS or die "can't close `$diffs': $!";

# print header
print <<"EOF";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml1.dtd">
<html><head>
<title>photogallery updates</title>
<meta http-equiv="content-type" content="text/html; charset=${CHARSET}" />
<link rel="alternate" type="application/rss+xml" title="RSS-Feed" href="$RSSURL">
</head><body>
<h1>photogallery updates</h1>
EOF
    ;

# print changes
print "<ul>\n";
foreach my $diff (reverse @diff) {
    my $date = $diff->{DATE};
    $date =~ s/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d).*$/$3.$2.$1 $4:$5h/;
    my $path = $diff->{PATH};
    $path =~ s/^$DIRPREFIX//;
    my $url = $WEBPREFIX.$path;
    $path =~ s:/index.html$::;

    my $text;

    if ($diff->{'OLD'} == 0) {
	$text = "neuer Ordner mit $diff->{'NEW'} Bildern";
    } elsif ($diff->{'NEW'} == 0) {
	# gelöscht, so what?
    } elsif ($diff->{'NEW'} > $diff->{'OLD'}) {
	$text = ($diff->{'NEW'} - $diff->{'OLD'}) . " neue Bilder";
    } else {
	$text = ($diff->{'OLD'} - $diff->{'NEW'}) . " Bilder gelöscht";
    }

    printf "<li>%s <a href=\"%s\">%s</a><br />%s<br /></li>\n",
    $date,
    $url,
    $path,
    $text
	if defined $text;
}
print "</ul>\n";

# print footer
my $date = `LANG=${DATELANG} date`;
chomp $date;
print "<p>(<a href=\"$RSSURL\">RSS feed</a>)</p>\n";
print "<p><small><small><i>generated on $date by ";
print '$Id: photogallery_diff2html.pl,v 1.4 2007-07-21 13:53:59 mitch Exp $';
print "</i></small></small></p></body></html>\n";
