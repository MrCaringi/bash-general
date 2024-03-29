#!/bin/bash
##########################################################################
###             Mounted Directory Check v1.0
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
#		2021-10-12	v1.0.0 refactor
#
##########################################################################

#   Current Version
    VERSION="v1.0.0"
##      In First place: verify Input and "jq" package
        #   Input Parameter
        if [ $# -eq 0 ]
            then
                echo $(date +%Y%m%d-%H%M%S)"	ERROR: Input Parameter is EMPTY!"
                exit 1
            else
                echo $(date +%Y%m%d-%H%M%S)"	INFO: Argument found: ${1}"
        fi
        #   Package Exist
        dpkg -s jq &> /dev/null
        if [ $? -eq 0 ] ; then
                echo $(date +%Y%m%d-%H%M%S)"	INFO: Package jq is present"
            else
                echo $(date +%Y%m%d-%H%M%S)"	ERROR: Package jq is not present!"
                exit 1
        fi

##      Getting the Main Configuration
    #   General Config
    DEBUG=`cat $1 | jq --raw-output '.GeneralConfig.Debug'`
    WAIT=`cat $1 | jq --raw-output '.GeneralConfig.Wait'`
    
    #   Telegram Config
    ENABLE_MESSAGE=`cat $1 | jq --raw-output '.Telegram.Enable'`
    CHAT_ID=`cat $1 | jq --raw-output '.Telegram.ChatID'`
    API_KEY=`cat $1 | jq --raw-output '.Telegram.APIkey'`

##  Functions
    function TelegramSendMessage(){
        #   Variables
        HEADER=${1}
        LINE1=${2}
        LINE2=${3}
        LINE3=${4}
        LINE4=${5}
        LINE5=${6}
        LINE6=${7}
        LINE7=${8}
        LINE8=${9}
        LINE9=${10}
        LINE10=${11}
        LINE11=${12}
        LINE12=${13}

        curl -s \
        --data parse_mode=HTML \
        --data chat_id=${CHAT_ID} \
        --data text="<b>${HEADER}</b>%0A      <i>from <b>#`hostname`</b></i>%0A%0A${LINE1}%0A${LINE2}%0A${LINE3}%0A${LINE4}%0A${LINE5}%0A${LINE6}%0A${LINE7}%0A${LINE8}%0A${LINE9}%0A${LINE10}%0A${LINE11}%0A${LINE12}" \
        "https://api.telegram.org/bot${API_KEY}/sendMessage"
    }

    function TelegramSendFile(){
        #   Variables
        HEADER=${1}
        LINE1=${2}
        FILE=${3}
        HOSTNAME=`hostname`

        curl -v -4 -F \
        "chat_id=${CHAT_ID}" \
        -F document=@${FILE} \
        -F caption="${HEADER}"$'\n'"        from: #${HOSTNAME}"$'\n'"${LINE1}" \
        https://api.telegram.org/bot${API_KEY}/sendDocument
    }

##   Start
    echo "################################################"
    echo "#                                              #"
    echo "#       STARTING MOUNTED DIR CHECK             #"
    echo "#                 ${VERSION}                       #"
    echo "#                                              #"
    echo "################################################"

    #   General Start time
        TIME_START=$(date +%s)
        DATE_START=$(date +%F)
    #   Setting Loop variables
        N=`jq '.Folders | length ' $1`
        i=0
	#   For Debug purposes
        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)"	DEBUG: "$DEBUG
        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)"	WAIT: "$WAIT
        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)"	ENABLE_MESSAGE: "$ENABLE_MESSAGE
        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)"	CHAT_ID: "$CHAT_ID
        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)"	API_KEY: "$API_KEY
        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)"	Task Qty: "$N
        [ $DEBUG == true ] && echo "================================================"



#   Entering into the Loop

#	Main section
    while [ $i -lt $N ]
    do
        echo "================================================"
        DIR=`cat $1 | jq --raw-output ".Folders[$i]"`
		I=$((i+1))
        echo $(date +%Y%m%d-%H%M%S)" Verifiying if $DIR is mounted"
        
		#	Verifying if folder is mounted
			if grep -qs $DIR /proc/mounts; then
				echo $(date +%Y%m%d-%H%M%S)" $DIR is Mounted."
			else
				echo $(date +%Y%m%d-%H%M%S)" $DIR is not Mounted."
				sudo mount $DIR
				if [ $? -ne 0 ]; then
					[ $ENABLE_MESSAGE == true ] && TelegramSendMessage "#MOUNTED_DIR_CHECK" "Task: ${I} / ${N}" "ERROR trying to mount:" "${DIR}" >/dev/null 2>&1
				fi
			fi
		sleep ${WAIT}
    	i=$(($i + 1))
    done

##   The end
    echo "================================================"
    echo $(date +%Y%m%d-%H%M%S)"	MOUNTED DIR CHECK Finished Task: ${I} of ${N}"

    echo "################################################"
    echo "#                                              #"
    echo "#       FINISHED MOUNTED DIR CHECK             #"
    echo "#                 ${VERSION}                       #"
    echo "#                                              #"
    echo "################################################"

    exit 0