#!/usr/bin/perl

my $number = 990,760;

$number =~ (/\d*+([\.,][\d*])?/);

print $number;