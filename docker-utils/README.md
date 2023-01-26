# DOCKER Mountpoint Check Script
Bash Script for verifying and self-healing unmounted mounpoints in docker containers

## What does this Script do:
- Verify if the mountpoint exist INSIDE the docker container,
- If the mountpoint does not exist, then a Telegram message is sent (if parameter Telegram.Enable is set "true"),
- Then, the docker container is restarted (as a workaround),
- After the Container got restarted, this script verify (up to 5 times) if the mountpoint is available,
- If not, then, another Telegram message is sent to notify it.
##   BEWARE!
`This script assumes that the user of this script can run "docker" without sudo`

## How to update/download the script to the lastest (stable) version
Type in the terminal:
```
wget -O docker-mount-check.sh https://raw.githubusercontent.com/MrCaringi/bash-general/master/docker-utils/docker-mount-check.sh && chmod +x docker-mount-check.sh

```
## How to Use
Open your terminal, then run:
```
bash docker-mount-check.sh config.json
```
![Terminal Start](https://github.com/MrCaringi/assets/blob/main/images/scripts/docker-mounpoint-check/terminal-start.png)

### Parameters
1 .json file

### Packages requirement
- `docker`    Container technology
- `jq`    Package for json data parsing

##  How to fill the config file (.json)
Example
```
{
    "GeneralConfig":{
        "Debug": true,
        "Wait": 5
        },

        "Telegram":{
        "Enable": true,
        "ChatID": "-123",
        "APIkey": "123:ABC"
        },

    "Tasks": [
        {
            "ContainerName": "name or ID of the docker container",
            "MountPoints":[
                "/path/to/check-1",
                "/path/to/check-2",
                "/path/to/check-3"
            ]
        },
        {
            "ContainerName": "transmission",
            "MountPoints":[
                "10.0.0.10:/volume1/downloads/torrents"
            ]
        }
    ]
}
```
### .json Instructions
| Parameter | Value | Description |
|---------------------- | -----------| ---------------------------------|
| GeneralConfig.Debug | true / false | Enable verbosity in the program log (recomended)|
| GeneralConfig.Wait | number | Seconds to wait between task (5 seconds recomended)|
| Telegram.Enable | true / false | Enable Telegram Notifications |
| Telegram.ChatID | number | Enable Telegram Notifications (you can get this when you add the bot @getmyid_bot to your chat/group) |
| Telegram.APIkey | alphanumeric | Telegram Bot API Key |
| Tasks.ContainerName | alphanumeric | name or ID of the docker container |
| Tasks.MountPoints | array/alphanumeric | Array of Full path of mountpoints INSIDE THE CONTAINER! |

### How to determine which MountPoints can be monitored
You can run the following command in your terminal, in order to know which mount-points are available insider the container:
```
docker exec <container name> cat /proc/mounts
```
Example:

![Terminal Mountpoints](https://github.com/MrCaringi/assets/blob/main/images/scripts/docker-mounpoint-check/terminal-mountpoints.png)

## Logs and Notifications
- Script Output example, when everything goes OK

![Terminal Output OK](https://github.com/MrCaringi/assets/blob/main/images/scripts/docker-mounpoint-check/terminal-output-ok.jpg)

- Script Output example, when there is a mountpount irrecoverable

![Terminal Output ERROR](https://github.com/MrCaringi/assets/blob/main/images/scripts/docker-mounpoint-check/terminal-output-error.jpg)

- Telegram Notification Example

![Telegram Notification](https://github.com/MrCaringi/assets/blob/main/images/scripts/docker-mounpoint-check/telegram-messages.jpg)

##  Version History
-       2023-01-26  v1.0.0  First version