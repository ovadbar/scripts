#!/bin/sh
#
# sendfax.sh
# created 31 Aug 2012
# Fred Posner <fred@palner.com>
#
# usage: sendfax.sh document 234567890
#
# check that arguments is present
#
if [ -z "$1" ]
	then
		echo -e "\n\n-----"
		echo -e "\033[1mUsage: sendfax.sh document 234567890\033[0m\n\n"
		exit 0
fi
if [ -z "$2" ]
	then
		echo -e "\n\n-----"
		echo -e "\033[1mUsage: sendfax.sh document 234567890\033[0m\n\n"
		exit 0
fi
#
# check that file exists
#
if ! [ -f $1 ]
	then
		echo -e "\n\n-----"
		echo -e "\033[1mError: $1 does not exist.\033[0m\n\n"
		exit 0
fi
#
# rm txfax.tiff
# make $1 into txfax.tiff
#

rm -f txfax.tiff
gs -q -r204x98 -g1728x1078 -dNOPAUSE -dBATCH -dSAFER -sDEVICE=tiffg3 -sOutputFile=txfax.tiff -- $1

if ! [ -f txfax.tiff ]
	then
		echo -e "\n\n-----"
		echo -e "\033[1mError: Fax file not created.\033[0m\n\n"
		exit 0
fi

echo -e "\n\n-----"
echo -e "\033[1mfile created. Sending to freeswitch.\033[0m\n\n"

/usr/local/freeswitch/bin/fs_cli -x "originate {origination_caller_id_name='FAX SERVER',origination_caller_id_number=0000000000}sofia/external/1$2@GATEWAY &txfax(/root/txfax.tiff)"


echo -e "\n\n-----"
echo -e "\033[1mall done.\033[0m\n\n"
