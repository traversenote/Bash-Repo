#!/usr/bin/perl
use strict; use warnings;

#Written by Jason Spears Jason@listeningpost.co.nz

#Source Files Declaration
my $junkFile = 'data.txt';
my $siteFile = 'sites.dat';
my $outputFile = 'siteStats.html';
my $title = 'Monthly site statistics report';
my $debugFile = 'debug.log';
my $remaining = `wc -l < $siteFile` - 1;

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
my ($lastMonth, $tidyDate, $formatTime) = currentTime(); my $site; my @result = (0); my $siteRank = ''; my $siteDelta = '';

#Open our files
open (OUTPUT, "+>$outputFile") or die $!; my $sites = open (SITES, $siteFile) or die $!; my $debugLog = open 
(DEBUG, "+>$outputFile") or die $!;



#We begin by introducing ourselves
print "\n\nThis script attempts to automatically pull down monthly stats for the month of 
$lastMonth from Alexa.com\nSites to be queried are located in $siteFile\nThe output is located in $outputFile\nTotal number of Sites to query: $remaining\n\n";

print OUTPUT "<!DOCTYPE HTML PUBLIC \"-\/\/W3C\/\/DTD HTML 4.01 Transitional\/\/EN\"\"http:\/\/www.w3.org\/TR\/html4\/loose.dtd\"><html lang=\"en\"><head><meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\"><title>$title<\/title><\/head><body>";
print OUTPUT "This report was generated at $formatTime on $tidyDate<\/br>Total number of sites: $remaining<\/br><\/br>";
print OUTPUT "<table width=\"50%\">";

#The actual work begins
while(my $line = <SITES>){
#Grab and parse info from siteFile
	if(index($line, 'SITE = ') != -1){
	chomp $line;
	$line =~ s/[SITE = ]//g;
	$site = $line;

#Query the URL
	my $queryURL = "http://data.alexa.com/data?cli=10\\&dat=s\\&url=$site";	
	my $feedBack = `curl -silent '$queryURL'`;
	#print "\n $queryURL \n";
	
#Open and write $file with the results
	open (JUNKFILE, ">$junkFile") or die $!;
	print JUNKFILE "$feedBack";	


#Parse the resulting file and pull out the stats we want
	my $data = open (JUNKFILE, $junkFile) or die $!;;
		while(my $line = <JUNKFILE>){

		#This part looks for the Site Rank Portion
			if(index($line, '<POPULARITY') != -1 ){
				$line =~ s/\D//g;
				push @result, $line;
				}	
			
		#Checks the Change
			if(index($line, '<RANK') != -1 ){
				$line =~ s/[A-Z, \<, \>, \=, \/, \"]//g;
				push @result, $line;
				}
			}
			
	#Grab the results and Tidy them Site Rank Portion
	$siteRank = $result[1];
	$siteDelta = $result[2];

	#Fail Safe if no data
	if (!defined $siteRank) { $siteRank = "None"; }
	if (!defined $siteDelta) { $siteDelta = "None"; }
	
	#Tidy Formatting
	$siteRank =~ s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g;
	$siteDelta =~ s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g;
	$remaining = $remaining -1;
	#Debug
	#print "Site rank: $siteRank \n";
	#print "Site rank Change: $siteDelta \n";
	
	print "Done $site Remaining items: $remaining \n";
	@result = '';
	
	print OUTPUT "<tr><td width=\"50%\">Site Statistics for: <strong>$site<\/strong><\/br><\/td><td>";
	print OUTPUT "Site Rank: <strong>$siteRank<\/strong><\/br><\/td><\/tr>";
	print OUTPUT "<tr><td><\/td><td>Site Rank Change: <strong>$siteDelta<\/strong><\/br><\/td><\/tr>";
	print OUTPUT "<tr><td>&nbsp;<\/td><\/tr>";
	}
}	
	print "\nAll sites queried successfully.\n";
	print OUTPUT "<\/table>";

print OUTPUT "<\/body><\/html>"; close (OUTPUT); close (JUNKFILE); close (SITES); close (DEBUG);
