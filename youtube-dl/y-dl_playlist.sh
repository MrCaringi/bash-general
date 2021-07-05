#!/bin/bash

###############################
#               YOUTUBE DOWNLOADER SCRIPT
#   This script will download your playlist videos to your local folder
#
##   HOW TO USE IT (in a Cron Job)
#	    0 12 * * * bash /path/rsync_replica.sh /path/to/rsync_replica.json >> /path/log
#
##  PARAMETERS
#   $1  Path to ".json" config file
#
##   REQUIREMENTS
#       - install youtube-dl https://github.com/ytdl-org/youtube-dl
#       - Packages: jq, ffmpeg
#
##	RSYNC CONFIGURATION File
#   Please see https://github.com/MrCaringi/borg/blob/master/rsync_replica.json for a example of "rsync_replica.json" file
#
#
##	SCRIPT MODIFICATION NOTES
#       2021-06-17  First version
#
###############################

##      Getting the Configuration
#   General Config
    DEBUG=`cat $1 | jq --raw-output '.config.Debug'`
    SEND_MESSAGE=`cat $1 | jq --raw-output '.config.SendMessage'`
    SEND_FILE=`cat $1 | jq --raw-output '.config.SendFile'`
    SETTING=`cat $1 | jq --raw-output '.config.Setting'`

#   Setting up variables
    N=`jq '.folders | length ' $1`
    i=0

#   For Debug purposes
    [ $DEBUG -eq "1" ] && echo "Debug:"$DEBUG
    [ $DEBUG -eq "1" ] && echo "SEND_MESSAGE:"$SEND_MESSAGE
    [ $DEBUG -eq "1" ] && echo "SEND_FILE:"$SEND_FILE
    [ $DEBUG -eq "1" ] && echo "SETTING:"$SETTING
    [ $DEBUG -eq "1" ] && echo "Paylists Qty:"$N
    [ $DEBUG -eq "1" ] && echo "i:"$i


##  If WOL was ok, then is time to RSYNC
    
    while [ $i -lt $N ]
    do
        echo "================================================"
        LABEL=`cat $1 | jq --raw-output ".folders[$i].Label"`
        PLAYLIST=`cat $1 | jq --raw-output ".folders[$i].From"`
        DIR_D=`cat $1 | jq --raw-output ".folders[$i].To"`

        #   For Debug purposes
            [ $DEBUG -eq "1" ] && echo "LABEL:"$LABEL
            [ $DEBUG -eq "1" ] && echo "PLAYLIST:"$PLAYLIST
            [ $DEBUG -eq "1" ] && echo "DIR_D:"$DIR_D
            [ $DEBUG -eq "1" ] && echo "N="$N
            [ $DEBUG -eq "1" ] && echo "i="$i   

        echo $(date +%Y%m%d-%H%M%S)" Starting with Playlist: ${LABEL}, to store in: ${DIR_D}"
        bash $SEND_MESSAGE "Youtube Playlist Downloader" "Starting with Playlist: ${LABEL}" "${PLAYLIST}" > /dev/null 2>&1
        
        START=$(date +"%Y%m%d %HH%MM%SS")
        
        #   The Magic goes here
        rand=$((1000 + RANDOM % 8500))
            echo "========== Youtube Playlist Downloader          $START" >> ydl-log_${rand}.log
        /usr/local/bin/youtube-dl --ignore-errors -f ${SETTING} -o ${DIR_D} ${PLAYLIST} >> ydl-log_${rand}.log 2>&1
        if [ $? -ne 0 ]; then
            echo $(date +%Y%m%d-%H%M%S)" ERROR Paylist Download: ${LABEL}"
            bash $SEND_MESSAGE "Youtube Playlist Downloader" "ERROR Paylist Download: " "${LABEL}" > /dev/null 2>&1
        fi    
        ##  Sending log to Telegram
        #   Building the log file
            echo "========== END           $(date +"%Y%m%d %HH%MM%SS")" >> ydl-log_${rand}.log
            #   Sending the File to Telegram
            bash $SEND_FILE "Youtube Playlist Downloader" "Log for ${LABEL}" ydl-log_${rand}.log > /dev/null 2>&1
            #   Flushing & Deleting the file
            cat ydl-log_${rand}.log
            rm ydl-log_${rand}.log

        sleep 5
        
        echo $(date +%Y%m%d-%H%M%S)" Finished with Playlist: ${LABEL}, to store in: ${DIR_D}"
        i=$(($i + 1))
    done
    exit 0