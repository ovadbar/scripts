#! /bin/bash
# use ghostscript to make a smaller pdf file
# ex. ./small-pdf.sh bigfile.pdf
# @fredposner / qxork.com - Oct 2020.
# Always be kind.

#-- functions
usage() {
 cat << _EOF_
Usage: ${0} "[file.pdf]"

_EOF_
}

echo "-> checking variables"
#-- check arguments and environment
if [ "$#" -ne "1" ]; then
  echo "Expected 1 arguments, got $#" >&2
  usage
  exit 2
fi

PDFFILE=$1
NEWFILE=${PDFFILE%.*}-small.pdf

echo "-> checking for ghostscript"
hash gs 2>/dev/null || { echo >&2 "I require ghostscript but it's not installed.  Aborting."; exit 1; }

echo "-> checking if pdf file exists"
if [ -e ${PDFFILE} ]
then
    echo " ... file exists"
else
    echo " ... cannot find $PDFFILE - aborting"
	echo "-> **ERROR** Cannot find the file provided. :("
	exit 2
fi

echo "-> compressing"
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$NEWFILE $PDFFILE

echo "-> done. New file is $NEWFILE"

