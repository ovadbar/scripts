#!/bin/bash
#
# run kamailio.kamailio_siptrace_callid and 
# move file to a filtered callid file name
#
# Fred Posner <fred@qxork.com>
# 2015-08-21
#

while getopts "c:p:" opt; do
  case $opt in
    c)
		CALLID=$OPTARG
		FILTEREDNAME=$(echo $CALLID | sed 's/[^a-zA-Z0-9\-]//g')
      ;;
    p)
      MYSQLPASSWORD=$OPTARG
      ;;
  esac
done


if [[ -z $CALLID ]] || [[ -z $FILTEREDNAME ]] || [[ -z $MYSQLPASSWORD ]]
then
     echo "-c CALLID and -p PASSWORD needed"
     exit 1
fi

mysql --user=kamailio --password=$MYSQLPASSWORD -e "call kamailio.kamailio_siptrace_callid('$CALLID');"
mv /tmp/sip_trace.txt /tmp/$FILTEREDNAME.txt

echo "file saved as /tmp/$FILTEREDNAME.txt"

