#!/usr/bin/perl -w
use strict;
$|=1;
my ($phone, $url, $apikey, $authkey, $result);

while(<STDIN>) {
	chomp;
	last unless length($_);
}

if ($ARGV[0]) {
	$phone = &URLEncode($ARGV[0]);
} else {
	&setvar("OPENCNAM", "No Phone");
	&setvar("CALLERID\(name)", "Unknown");
	&printverbose("OPENCNAM: No CALLFROM received.",2);
	exit(0);
}

#Get the cid
$apikey = "APIKEY";
$authkey = "AUTHKEY";
$url = "api.opencnam.com/v2/phone/";

$result = qx(curl -m 2 -s https://$apikey:$authkey\@$url+1$phone?format=text);

#or free version would be...

#$result = qx(curl -m 2 -s https://api.opencnam.com/v2/phone/+1$phone);

if ($result) {
	&setvar("OPENCNAM", "$result");
	&setvar("CALLERID\(name)", "$result");
	&printverbose("OPENCNAM: $result.",2);
} else {
	&setvar("OPENCNAM", "FAIL");
	&setvar("CALLERID\(name)", "Unknown");
	&printverbose("OPENCNAM: Timeout or error",2);
}

sub URLEncode {
   my $theURL = $_[0];
   $theURL =~ s/([\W])/"%" . uc(sprintf("%2.2x",ord($1)))/eg;
   return $theURL;
}

sub setvar {
	my ($var, $val) = @_;
	print STDOUT "SET VARIABLE $var \"$val\" \n";
	while(<STDIN>) {
		m/200 result=1/ && last;
	}
	return;
}

sub printverbose {
	my ($var, $val) = @_;
	print STDOUT "VERBOSE \"$var\" $val\n";
	while(<STDIN>) {
		m/200 result=1/ && last;
	}
	return;
}
