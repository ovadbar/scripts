#!/usr/bin/perl
# July 2012
# Fred Posner <fred@qxork.com>
# http://qxork.com

use strict;
use MIME::Lite;

my ($msg,$fax,$pdffile,$from,$to);

# $ARGV[0] = filename
# $ARGV[1] = to name
# $ARGV[2] = from name

if ($ARGV[0]) 
{
	$fax = $ARGV[0];
	$pdffile = "/tmp/$fax.tif";
} 
else 
{
	print "No file provided.\n";
	exit(0);
}

if ($ARGV[1])
{
	if (&Checkemail($ARGV[1]) eq "Pass")
	{
		$to = $ARGV[1];
	}
	else
	{
		print "Not valid to email.\n"
		exit(0);
	}
}
else
{
	$to = "DEFAULT\@DOMAIN";
}

if ($ARGV[2])
{
	if (&Checkemail($ARGV[2]) eq "Pass")
	{
		$from = $ARGV[2];
	}
	else
	{
		print "Not valid from email.\n"
		exit(0);
	}
}
else
{
	$from = "DEFAULT\@DOMAIN";
}

unless (-e $pdffile) 
{
	$msg = `echo "A failed fax attempted by $fax.\n\nThank You." | mail -s "Failed Fax from $fax" $to -- -f $from`;
} 
else 
{
	system("tiff2ps -a /tmp/$fax.tif | ps2pdf13 -sPAPERSIZE=letter - > /tmp/$fax.pdf");

	$msg = MIME::Lite->new(
		From => "$from",
		To => "$to",
		Subject => "FAX Received",
		Type => 'multipart/mixed'
	);

	$msg->attach(
		Type => 'TEXT',
		Data => "Greetings.\n\nYou have received a fax from $fax (attached).\n\n\n"
	);

	$msg->attach(
		Type => 'image/pdf',
		Path => "/tmp/$fax.pdf",
		Filename => "$fax.pdf",
		Disposition => 'attachment'
	);

	MIME::Lite->send('smtp','localhost',Timeout=>60);

	$msg->send;

	system("rm -f /tmp/$fax.pdf");
}
#sendfax.pl fax-20090824-170217 [to] [from]

1

sub Checkemail($) 
{
	my $string = $_[0];

	if ($string =~ /[a-zA-Z0-9\.\-]{1,}[\@][a-zA-Z0-9\-]{1,}[\.a-zA-Z0-9\-]{1,}$/) 
	{ 
		return "Pass";
	} 
	else 
	{
		return "Fail";
	}
}
