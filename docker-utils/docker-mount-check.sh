#!/bin/bash

#       2023-01-17  First version

##########################################################################
###             Mounted Directory Check for Docker Containers v1.0
# SUMMARY:
#	Verify if a list of directories are mounted inside a docker container, if not:
#   - send a telegram message
#   - restart the container in order to try to mount it
# 
##  PARAMETERS
#   $1  Path to ".json" config file
#	Example:
#	bash docker-mount-check.sh config.json
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
        which jq &> /dev/null
        if [ $? -eq 0 ] ; then
                echo $(date +%Y%m%d-%H%M%S)"	INFO: Package jq is present"
            else
                echo $(date +%Y%m%d-%H%M%S)"	ERROR: Package jq is not present!"
                exit 1
        fi
        which docker &> /dev/null
        if [ $? -eq 0 ] ; then
                echo $(date +%Y%m%d-%H%M%S)"	INFO: Package docker is present"
            else
                echo $(date +%Y%m%d-%H%M%S)"	ERROR: Package docker is not present!"
                exit 1
        fi

##      Getting the Main Configuration
    #   General Config
    DEBUG=$(cat $1 | jq --raw-output ".GeneralConfig.Debug")
    WAIT=$(cat $1 | jq --raw-output ".GeneralConfig.Wait")
    
    #   Telegram Config
    ENABLE_MESSAGE=$(cat $1 | jq --raw-output ".Telegram.Enable")
    CHAT_ID=$(cat $1 | jq --raw-output ".Telegram.ChatID")
    API_KEY=$(cat $1 | jq --raw-output ".Telegram.APIkey")

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
    echo "#       STARTING DOCKER MOUNT CHECK            #"
    echo "#                 ${VERSION}                       #"
    echo "#                                              #"
    echo "################################################"

    #   General Start time
        TIME_START=$(date +%s)
        DATE_START=$(date +%F)

    #   Setting Loop variables
        N=$(jq ".Tasks | length " $1)
        i=0     #   Main loop counter
        j=0     #   Inner loop counter
        I=0     #   Task counter
        J=0     #   Inner task counter
        M=0     #   Inner mountpoint Qty

	#   For Debug purposes
        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)"	DEBUG: "$DEBUG
        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)"	WAIT: "$WAIT
        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)"	ENABLE_MESSAGE: "$ENABLE_MESSAGE
        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)"	CHAT_ID: "$CHAT_ID
        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)"	API_KEY: "$API_KEY
        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)"	Task Qty: "$N
        [ $DEBUG == true ] && echo "════════════════════════════════════════════════════════════════════════════════════════════════"

#   Entering into the Loop

#	Main loop
    while [ $i -lt $N ]
    do
        [ $DEBUG == true ] && echo "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"
        
        #   Intitializing inner loop variables
            j=0
            M=$(jq ".Tasks[$i].MountPoints | length " $1)
        
        #   Task Info
            I=$((i+1))
            ContainerName=$(jq --raw-output ".Tasks[$i].ContainerName " $1)
            [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)" Task Counter: "$I
            [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)" Task Container Name: "$ContainerName
            [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)" Task Number of mountpoints to check: "$M
        
        #   Inner lopp
            while [ $j -lt $M ]
            do
                [ $DEBUG == true ] && echo "------------------------------------------------------------------------------------------------"
                #   Inner loop info
                    k=0
                    J=$((j+1))
                    [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)"	Inner task counter, J: $J / $M"
                    MountPoint=$(jq --raw-output ".Tasks[$i].MountPoints[$j] " $1)
                    [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)" Task Container Mount-Point: "$MountPoint
                
                #   Magic goes here!
                    #	Verifying if folder is mounted
                        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)" Verifying if folder is mounted "
                        [ $DEBUG == true ] && echo
                        if docker exec $ContainerName grep $MountPoint /proc/mounts; then
                            #	Ok, it is mounted
                            [ $DEBUG == true ] && echo
                            [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)" *** OK ***: for container $ContainerName, the mount-point $MountPoint is Present."
                        else
                            #	ERROR, it is NOT mounted
                            [ $DEBUG == true ] && echo
                            [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)" *** ERROR ***: for container $ContainerName, the mount-point $MountPoint is MISSING."
                            [ $ENABLE_MESSAGE == true ] && TelegramSendMessage "#DOCKER_MOUNTPOINT_MONITOR" "Task: ${ContainerName} (${I} / ${N})" "Mount-point missing (${J} / ${M}):" "${MountPoint}" >/dev/null 2>&1

                            #   Restarting the container
                                [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)" Container $ContainerName, is being restarted"
                                docker restart $ContainerName > /dev/null
                                [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)" Container $ContainerName, has been restarted"

                            #   Waiting and verifying loop
                                MISSING="false"
                                while [ $k -lt 5 ]
                                do
                                    #   Verify if container is running
                                        sleep ${WAIT}
                                        STATUS=$( docker container inspect -f '{{.State.Status}}' $ContainerName )
                                        [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)" Container $ContainerName, has the State.Status: "$STATUS
                                        if [ $STATUS == "running" ]; then
                                            sleep ${WAIT}
                                            # Verify if mount point is present
                                                if docker exec -it $ContainerName grep $MountPoint /proc/mounts; then
                                                    echo $(date +%Y%m%d-%H%M%S)" *** OK ***: for container $ContainerName, the mount-point $MountPoint is NOW AVAILABLE."
                                                    [ $ENABLE_MESSAGE == true ] && TelegramSendMessage "#DOCKER_MOUNTPOINT_MONITOR" "Task: ${ContainerName} (${I} / ${N})" "Mount-point was fixed! (${J} / ${M}):" "${MountPoint}" >/dev/null 2>&1
                                                    break
                                                else
                                                    echo $(date +%Y%m%d-%H%M%S)" *** WARNING ***: for container $ContainerName, the mount-point $MountPoint is MISSING."
                                                    MISSING="true"
                                                fi
                                        fi
                                    k=$(($k + 1))
                                    [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)" Waiting and verifying counter, k: "$k
                                done
                                #   unrecovery notification
                                    [ $DEBUG == true ] && echo $(date +%Y%m%d-%H%M%S)" MISSING value: "$MISSING
                                    if [ $MISSING == true ]; then
                                        echo $(date +%Y%m%d-%H%M%S)" *** ERROR ***: for container $ContainerName, the mount-point $MountPoint was IRRECOVERABLE."
                                        [ $ENABLE_MESSAGE == true ] && TelegramSendMessage "#DOCKER_MOUNTPOINT_MONITOR" "Task: ${ContainerName} (${I} / ${N})" "Mount-point was #IRRECOVERABLE! (${J} / ${M}):" "${MountPoint}" >/dev/null 2>&1
                                    fi
                        fi
                #   Finishing inner loop
                    #sleep ${WAIT}
                    j=$(($j + 1))
            done
        i=$(($i + 1))
    done

##   The end
    [ $DEBUG == true ] && echo "════════════════════════════════════════════════════════════════════════════════════════════════"
    echo $(date +%Y%m%d-%H%M%S)"	MOUNTED DIR CHECK Finished Task: ${I} of ${N}"

    echo "################################################"
    echo "#                                              #"
    echo "#        FINISH DOCKER MOUNT CHECK             #"
    echo "#                 ${VERSION}                       #"
    echo "#                                              #"
    echo "################################################"

    exit 0

##############################################################
#       MODIFICATION NOTES:
#
#       2023-01-17  First version
#
##############################################################