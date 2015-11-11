#!/usr/bin/perl
use strict; use warnings;
######################################################################################
#
#  Copyright 2014 by Jason Spears, All Rights Reserved
#
#  To the maximum extent permitted by applicable law, in no event shall
#  Jason Spears or its employees be liable for any special,
#  incidental,  indirect, or consequential damages whatsoever (including,
#  without limitation, damages for loss of business profits, business interruption,
#  loss of business information, or any other pecuniary loss) arising out
#  of the use of or inability to use this software product or the provision
#  of or failure to provide support services, even if Jason Spears
#  has been advised of the possibility of such damages.
#
#  THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
#  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
#  PURPOSE.
#
#  http://www.sr-studio.com
#  jspears@sr-studio.com
#
######################################################################################
#	Updates to version 1.4
#		Added the "National Rank" stat
#		Added the copyright text above
#
#
#


#Source Files Declaration
my $junkFile = 'data.txt';
my $siteFile = 'sites.dat';
my $outputFile = '/storage/downloads/siteStats.html';
my $title = 'Monthly site statistics report';
my $debugFile = 'debug.log';


#shared Functions Gets the *Previous* month
sub currentTime {
	my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
	# You add 1 because the number in $month is based on a starting number of 0. So, if $month is 0, then $monthnum is 1 (ie: January) Adding 1 
	# gets you a number from the list below.
	my $monthnum = $month +1;
	my $lastMonthnum = $month;
	if (length($minute) == '1'){$minute = "0$minute";}
	$yearOffset += 1900;
	if ($lastMonthnum == 0){$lastMonthnum = 12;}
	my %monthname = (
                  1 => 'January',
                  2 => 'February',
                  3 => 'March',
                  4 => 'April',
                  5 => 'May',
                  6 => 'June',
                  7 => 'July',
                  8 => 'August',
                  9 => 'September',
                 10 => 'October',
                 11 => 'November',
                 12 => 'December',
	);
	my %weekDay = (
					1 => 'Monday',
					2 => 'Tuesday',
					3 => 'Wednesday',
					4 => 'Thursday',
					5 => 'Friday',
					6 => 'Saturday',
					7 => 'Sunday',
	);
	my $formatTime = "$hour:$minute";
	my $tidyDate = "$weekDay{$dayOfWeek}, $dayOfMonth $monthname{$monthnum}, $yearOffset";
	
	return ($monthname{$lastMonthnum}, $tidyDate, $formatTime);
}

#Initialize Variables to make this thing work
my ($lastMonth, $tidyDate, $formatTime) = currentTime(); my $site; my @result = (0); my $siteRank = ''; my 
$siteLinks = ''; my $nationalRank = '';

#Open our files
open (OUTPUT, "+>$outputFile") or die $!; my $sites = open (SITES, $siteFile) or die $!; my $debugLog = open 
(DEBUG, "+>$outputFile") or die $!;

#We begin by introducing ourselves
print "\n\nThis script attempts to automatically pull down monthly stats for the month of 
$lastMonth from Alexa.com\nSites to be queried are located in $siteFile\nThe output is located in $outputFile\n"; 
print OUTPUT "<!DOCTYPE HTML PUBLIC \"-\/\/W3C\/\/DTD HTML 4.01 Transitional\/\/EN\"\"http:\/\/www.w3.org\/TR\/html4\/loose.dtd\"><html lang=\"en\"><head><meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\"><title>$title<\/title><\/head><body>";
print OUTPUT "This report was generated at $formatTime on $tidyDate<\/br><\/br>";

#The actual work begins
while(my $line = <SITES>){
#Grab and parse info from siteFile
	if(index($line, 'SITE = ') != -1){
	chomp $line;
	$line =~ s/[SITE = ]//g;
	$site = $line;
	
#Query the URL
	my $queryURL = "http://www.alexa.com/siteinfo/$site";
	my $feedBack = `curl -silent $queryURL`;
	
#Open and write $file with the results
	open (JUNKFILE, ">$junkFile") or die $!;
	print JUNKFILE "$feedBack";
#Parse the resulting file and pull out the stats we want
	my $data = open (JUNKFILE, $junkFile) or die $!;;
		while(my $line = <JUNKFILE>){
			
		#This part looks for the Site Rank Portion
			if(index($line, 'Global rank icon') != -1 ){
				push @result, $line;
				while($line = <JUNKFILE>){
					last if $line =~ "class=";
					push @result, $line;
				}	
			}
		#Check for the National Site Rank Portion
			if(index($line, 'metrics-data align-vmiddle') != -1 && index($line, 'New Zealand Flag') !=1){
				push @result, $line;
				while($line = <JUNKFILE>){
					last if $line =~ "class=";
					push @result, $line;
					}
				}
		#Checks the number of Sites Linking In
			if(index($line, 'Sites Linking Inxx') != -1){
				push @result, $line;
				while($line = <JUNKFILE>){
					last if $line =~ "</div>";
					push @result, $line;
				}
			}
			
		}
		
	#Grab the results and Tidy them Site Rank Portion
	$siteRank = $result[1];
	$siteRank =~ m/((\d+,)(\d+,)*(\d+)*)/;
	$siteRank = $1;

	if (!defined $siteRank) {
		$siteRank = "None";
	}
	
	$nationalRank = $result[2];
	$nationalRank =~ m/((\d+,)(\d+,)*(\d+)*)/;
	$nationalRank = $1;

	if (!defined $nationalRank || $nationalRank eq $siteRank){
		$nationalRank = "None";
	}
	print "Done $site\n";
	@result = '';
	
	print OUTPUT "<table width=\"50%\">";
	print OUTPUT "<tr><td width=\"50%\">Site Statistics for: <strong>$site<\/strong><\/br><\/td><td><\/td><\/tr>";
	print OUTPUT "<tr><td><\/td><td>Site Rank: <strong>$siteRank<\/strong><\/br><\/td><\/tr>";
	print OUTPUT "<tr><td><\/td><td>National Rank: <strong>$nationalRank<\/strong><\/br><\/td><\/tr>";
#	print OUTPUT "<tr><td><\/td><td>Sites Linking in: <strong>$siteLinks<\/strong><\/br><\/td><\/tr>";
	print OUTPUT "<\/table>";
	
	}
}
#if (unlink($junkFile) == 0) {
#    print "Housekeeping failed. Unable to delete $junkFile.\n Feel free to delete it manually.\n";
#} else {
#    print "\n\nDone\n";
#}
print OUTPUT "<\/body><\/html>"; close (OUTPUT); close (JUNKFILE); close (SITES); close (DEBUG);
