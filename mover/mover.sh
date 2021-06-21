###############################
#       MOVER Script v1     (Tú agente de mudanzas!)
#
#	sh mover.sh /path/to/mover.json
#
#
#   Dependencies
#       - Package: jq
#
#	MODIFICATION LOG
#		2021-06-21  Alpha version
#
###############################

#   Manual example_
#   find /mnt/nostromo-downloads/complete/ -iname "*motogp*" -exec mv {} /mnt/nostromo-video/Racing/MotoGP/ \;

##      Getting the Configuration
#   General Config
    DEBUG=`cat $1 | jq --raw-output '.config.Debug'`
    SEND_MESSAGE=`cat $1 | jq --raw-output '.config.SendMessage'`
    SEND_FILE=`cat $1 | jq --raw-output '.config.SendFile'`
    Sleep=`cat $1 | jq --raw-output '.config.Sleep'`

#   Setting up variables
    N=`jq '.folders | length ' $1`
    i=0

#   For Debug purposes
    [ $DEBUG -eq "1" ] && echo "Debug:"$DEBUG
    [ $DEBUG -eq "1" ] && echo "SEND_MESSAGE:"$SEND_MESSAGE
    [ $DEBUG -eq "1" ] && echo "SEND_FILE:"$SEND_FILE
    [ $DEBUG -eq "1" ] && echo "Sleep:"$Sleep
    [ $DEBUG -eq "1" ] && echo "PATTERNS Qty:"$N
    [ $DEBUG -eq "1" ] && echo "i:"$i


##  Into the loop
    
    while [ $i -lt $N ]
    do
        START=$(date +"%Y%m%d %HH%MM%SS")
        echo "================================================"
        Pattern=`cat $1 | jq --raw-output ".folders[$i].Pattern"`
        From=`cat $1 | jq --raw-output ".folders[$i].From"`
        To=`cat $1 | jq --raw-output ".folders[$i].To"`

        #   For Debug purposes
            [ $DEBUG -eq "1" ] && echo "Pattern:"$Pattern
            [ $DEBUG -eq "1" ] && echo "From:"$From
            [ $DEBUG -eq "1" ] && echo "To:"$To
            [ $DEBUG -eq "1" ] && echo "N="$N
            [ $DEBUG -eq "1" ] && echo "i="$i   

        echo $(date +%Y%m%d-%H%M%S)" MOVER is working on pattern: ${Pattern}, from: ${From}, to: ${To}"
        
        
        #   The Magic goes here
            rand=$((1000 + RANDOM % 8500))
            echo "========== MOVER          $START" > mover-log_${rand}.log

            find "${From}" -iname "${Pattern}" -exec mv {} "${To}" \; >> mover-log_${rand}.log 2>&1
            
            if [ $? -eq 1 ]; then
                ##  Sending log to Telegram
                #   Building the log file
                echo $(date +%Y%m%d-%H%M%S)" MOVER, found a coincidence for pattern: ${Pattern}"
                echo "========== END           $(date +"%Y%m%d %HH%MM%SS")" >> mover-log_${rand}.log
                #   Sending the File to Telegram
                bash $SEND_FILE "MOVER" "found a coincidence for pattern:$LABEL" mover-log_${rand}.log >/dev/null 2>&1
            fi    
            
                
            #   Flushing & Deleting the file
            rm mover-log_${rand}.log
            sleep $Sleep
            echo $(date +%Y%m%d-%H%M%S)" MOVER finished with pattern: ${Pattern}"
            i=$(($i + 1))
    done
    exit 0