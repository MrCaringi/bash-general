#!/bin/bash
##########################################################################
###             Automount Directory Check v0.1
# SUMMARY:
#	Verify if a list of directories are mounted, if not, send a telegram message and try to mount it
# 
##  PARAMETERS
#   $1  Path to ".json" config file (see rest of file in repo: https://github.com/MrCaringi/bash-general.git )
#	Example:
#	bash mounted-dir-check.sh mounted-dir.json
#
##   REQUIREMENTS
#       - sudo mode in order to mount the directory
#		- recomended: put it in root crontab configuration
#
##	.JSON CONFIGURATION File
#   Please see https://github.com/MrCaringi/borg/blob/master/rsync_replica.json for a example of "rsync_replica.json" file
#
#  It must include:
#	in CONFIG section
#		"SendMessage": full path and script name used for Sending Messages to Telegram, example: https://github.com/MrCaringi/notifications/blob/master/telegram-message.sh
#   in FOLDERS section
#       Just the array of folders to replicate to remote server
#
##	SCRIPT MODIFICATION NOTES
#       2020-09-01  First version
#
#
##########################################################################

##      Getting Configuration
SEND_MESSAGE=`cat $1 | jq --raw-output '.config.SendMessage'`

#	Log start
	now=$(date +"%Y-%m-%d %H:%M:%S")
	echo "vvv $now vvv START vvv"

#	Main section
	N=`jq '.folders | length ' $1`
    i=0
    while [ $i -lt $N ]
    do
        echo "================================================"
        DIR=`cat $1 | jq --raw-output ".folders[$i]"`
        echo $(date +%Y%m%d-%H%M%S)" Verifiying if $DIR is mounted"
        #   For Debug Purposes
        	#echo "DIR: "$DIR
        	#echo "N="$N
        	#echo "i="$i
			#echo "send mensage program: "$SEND_MESSAGE
        
		#	Verifying if folder is mounted
			if grep -qs $DIR /proc/mounts; then
				echo "$DIR is Mounted."
			else
				echo "Not mounted."
				mount $DIR
				if [ $? -ne 0 ]; then
					bash $SEND_MESSAGE "MOUNT DIR CHECK" "ERROR trying to mount" "${DIR}" > /dev/null
				fi
			fi
		sleep 2
    	i=$(($i + 1))
    done
#	Log ends
	now=$(date +"%Y-%m-%d %H:%M:%S")
	echo "^^^ $now ^^^ END ^^^"

exit 0