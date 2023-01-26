# Mounted Directory Check Script
Bash Script for verifying and self-healed unmounted directories

##   BEWARE!
`sudo mount` is used in order to try to mount the directory, so, current user needs to able to use `sudo` without password.

## How to Use
Open your terminal, then run
```
bash /path/mount-check.sh /path/config.json
```

### Parameters
1 .json file

### Packages requirement
- `jq`    Package for json data parsing

##  How to fill the config file (.json)
Example
```
{
    "GeneralConfig":{
        "Debug": true,
        "Wait": 2
        },
    "Telegram":{
        "Enable": true,
        "ChatID": "-123",
        "APIkey": "123:ABC"
        },

    "Folders": [
        "/local/mounted/dir/1",
        "/local/mounted/dir/2",
        "/local/mounted/dir/3"
    ]
}
```
### .json Instructions
| Parameter | Value | Description |
|---------------------- | -----------| ---------------------------------|
| GeneralConfig.Debug | true / false | Enable more verbosity in the program log |
| GeneralConfig.Wait | number | Seconds to wait between task |
| Telegram.Enable | true / false | Enable Telegram Notifications |
| Telegram.ChatID | number | Enable Telegram Notifications (you can get this when you add the bot @getmyid_bot to your chat/group) |
| Telegram.APIkey | alphanumeric | Telegram Bot API Key |
| Folders | Path | Full path to Directory |

##  Version Story
-       2020-09-01  First version
-		2021-10-12	v1.0.0 refactor