#!/usr/bin/perl
# $Id: photogallery_diff2rss.pl,v 1.3 2007-08-12 17:29:21 mitch Exp $
#
# converts photogallery.sh changes to HTML page
#
# 2007 (c) by Christian Garbs <mitch@cgarbs.de>
#

use strict;
use warnings;

use Digest::MD5 qw(md5_hex);
use POSIX qw(strftime);

# parse configuration file
my %conf;
eval(`cat ~/.photogallery-conf.pl`);

# check variables
foreach (qw( DATADIR DIRPREFIX WEBPREFIX CHARSET CHANGESURL RSSTITLE RSSAUTHOR )) {
    die "configuration key $_ is missing\n" unless exists $conf{$_};
}

# get old diffs
my @diff;
my $diffs = "$conf{DATADIR}/last_diffs";

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
<?xml version="1.0" encoding="${conf{CHARSET}}"?>
<rss version="2.0"
 xmlns:dc="http://purl.org/dc/elements/1.1/"
 xmlns:content="http://purl.org/rss/1.0/modules/content/">
  <channel>
    <title>$conf{RSSTITLE}</title>
    <link>$conf{CHANGESURL}</link>
    <description>$conf{RSSTITLE}</description>
EOF
;
print '    <generator>$Id: photogallery_diff2rss.pl,v 1.3 2007-08-12 17:29:21 mitch Exp $</generator>';
print "\n";

# print changes
my $timezone = `date +%z`;
chomp $timezone;
foreach my $diff (reverse @diff) {
    my $date = $diff->{DATE};
    $date = strftime("%a, %d %b %Y %H:%M:%S $timezone", substr($date,12,2), substr($date,10,2), substr($date,8,2), substr($date,6,2), substr($date,4,2)-1, substr($date,0,4)-1900);
    my $path = $diff->{PATH};
    $path =~ s/^$conf{DIRPREFIX}//;
    my $url = $conf{WEBPREFIX}.$path;
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

    next unless defined $text;

    # get thumbnail
    my $pic;
    my $thumbdir = $diff->{PATH};
    $thumbdir =~ s:index.html:.webthumbs/:;
    opendir THUMBS, $thumbdir or die "can't opendir `${thumbdir}': $!";
    while (my $file = readdir (THUMBS)) {
	if ($file =~ /_s.jpg$/) {
	    $pic = $file;
	    last;
	}
    }
    closedir THUMBS or die "can't closedir `${thumbdir}': $!";
    if ($pic) {
	$thumbdir =~ s/^$conf{DIRPREFIX}/$conf{WEBPREFIX}/;
	$text .= "<p><img src=\"$thumbdir$pic\"></p>";
    }

    my $guid = md5_hex( $url . $path . $text . $date );

    printf <<"EOF"
    <item>
      <title><![CDATA[${path}]]></title>
      <content:encoded>\n<![CDATA[${text}]]></content:encoded>
      <pubDate>$date</pubDate>
      <dc:creator>$conf{RSSAUTHOR}</dc:creator>
      <guid isPermaLink=\"false\">${guid}</guid>
      <link>${url}</link>
    </item>
EOF
;
}

# print footer
print "  </channel>\n";
print "</rss>\n";
