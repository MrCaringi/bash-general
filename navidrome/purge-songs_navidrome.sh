#!/bin/bash

#   VARIABLES
    # Database file path (replace with your actual path)
        DATABASE_FILE="/mnt/services/navidrome/navidrome.db"
        echo "DATABASE_FILE="$DATABASE_FILE

    #   Path to temp file to store the song paths to be deleted
        PATH_SONGS_FILE="/home/ubuntu/scripts/tools/purge-songs/songs.txt"
        touch $PATH_SONGS_FILE

    #   Variables required to change the paths from the relative form (because of docker volumes) to the absolute/real path
        PATH_PREFIX="/mnt/decoupled-services/music/music_library"
            echo "PATH_PREFIX="$PATH_PREFIX
        PATH_PREFIX_2_replace="/music"
            echo "PATH_PREFIX_2_replace="$PATH_PREFIX_2_replace
    
    # SQLite3 command location (adjust if needed)
        SQLITE3_CMD="sqlite3"

        # Check if sqlite3 command exists
            if ! command -v "$SQLITE3_CMD" &> /dev/null; then
            echo "Error: sqlite3 command not found. Please install sqlite3."
            exit 1
            fi

    #   Telegram VARS
        CHAT_ID="9999999999"
        API_KEY="999:ABCabc"

#   FUNCTIONS
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

# SQL statements
GET_SONGS_WITH_RATING_1="select files.path
from media_file as files
join annotation as ratings on files.id = ratings.item_id
where ratings.rating = 1 and ratings.item_type = 'media_file';"

    #echo "GET_SONGS_WITH_RATING_1=""${GET_SONGS_WITH_RATING_1}"

    #   Export the paths to file
        $SQLITE3_CMD "$DATABASE_FILE" <<< "$GET_SONGS_WITH_RATING_1" > $PATH_SONGS_FILE

    #   Adjust the right path of files
        sed -i "s|$PATH_PREFIX_2_replace|$PATH_PREFIX|g" $PATH_SONGS_FILE
        cat $PATH_SONGS_FILE

# Loop through songs and delete files
    echo $(date +%Y%m%d-%H%M%S)" Deleting songs with rating 1:"

    # Read the songs file line by line and delete them
        while IFS= read -r linea; do
            # Verify if the path is valid
            if [ -e "$linea" ]; then
                echo "Deleting file: $linea"
                rm "$linea"
            else
                echo "File $linea does not exist."
                TelegramSendMessage "#MUSIC_PURGE" " " "Error when deleteing this file" "${linea}" >/dev/null 2>&1
                sleep 1
            fi
        done < "$PATH_SONGS_FILE"

#   Notifications
    TelegramSendFile "#MUSIC_PURGE" "List of 1 starred songs" ${PATH_SONGS_FILE} >/dev/null 2>&1


    #   Delete empty folders
        echo $(date +%Y%m%d-%H%M%S)" Delete empty folders."
        find ${PATH_PREFIX} -type d ! -name '.*' -empty -print -delete > ${PATH_SONGS_FILE}
        TelegramSendFile "#MUSIC_PURGE" "Deleted folders" ${PATH_SONGS_FILE} >/dev/null 2>&1

#   Ending
    rm $PATH_SONGS_FILE

    echo $(date +%Y%m%d-%H%M%S)" Done."



