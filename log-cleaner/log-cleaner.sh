#!/bin/bash

###############################
#           LOG CLEANER v1
#
#	bash logcleaner.sh /path/to/log-cleaner.json
#
#	Parameters
#	1 $REP_DIR     configuration file path
#	2 
# 
#	Modification Log
#		2020-03-07  Alpha version
#       2020-03-08  Beta version
#
###############################

##      Getting the Configuration
    NEWLINES=`cat $1 | jq --raw-output '.config.NewLines'`
    LIMITLINES=`cat $1 | jq --raw-output '.config.LimitLines'`
    SEND_MESSAGE=`cat $1 | jq --raw-output '.config.SendMessage'`
    SEND_FILE=`cat $1 | jq --raw-output '.config.SendFile'`
#   Getting number of files
    N=`jq '.repository | length ' $1`
    i=0
#   File loop
    while [ $i -lt $N ]
    do
        echo "==========================================================="
        FILE=`cat $1 | jq --raw-output ".repository[$i]"`
        echo $(date +%Y%m%d-%H%M)" Starting Check of $FILE"
        START=$(date +"%Y%m%d %HH%MM%SS")
        
                
        file_check=$(wc -l $FILE | cut -d ' ' -f 1)
        #   wc -w $FILE | cut -d ' ' -f 1
        #   wc -l < $FILE
        
        if [ $file_check -gt $LIMITLINES ]; then
            echo $(date +%Y%m%d-%H%M)" $FILE has more than $LIMITLINES Lines (actual lines: $file_check)"
            SEEK=$(($file_check - $NEWLINES))
            tail -n +$SEEK $FILE > $FILE.tmp && mv $FILE.tmp $FILE
            echo $(date +%Y%m%d-%H%M)" $FILE has been truncated to kept last $NEWLINES lines"
            bash $SEND_FILE "Log Cleaner" "this file had $file_check lines" $FILE > /dev/null 2>&1
        fi
        i=$(($i + 1))
        echo "i="$i
    done
exit 0