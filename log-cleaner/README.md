# LOG CLEANER

### Objetive
This is a simple bash script for deleting the first N lines of a file,
I create this for clean some logs non located in /var/log directories.

### Preparation
This scripts needs the following componets
- the .sh script it self
- the .json configuration file
- the "SendMessage" script for telegram notifications, it can be found here [Git Repository for Telegram Scripts](https://github.com/MrCaringi/notifications)
- the "SendFile" script for telegram notifications, it can be found here [Git Repository for Telegram Scripts](https://github.com/MrCaringi/notifications)

#### How to populate log-cleaner.json
~~~
{
    "config":{
        "NewLines": 100,   # last number of lines that will be kept
        "LimitLines": 1000,    # Mininal number of lines in order to be candidate for truncating the first lines
        "SendMessage": "/path/telegram-message.sh",    # path and script where the "Send Telegram Message" script exist
        "SendFile": "/path/telegram-message-file.sh"    # path and script where the "Send Telegram File" script exist
    },
    "repository": [    # list of files to be monitoring
        "/borg/repository/dir/1",
        "/borg/repository/dir/2",
        "/borg/repository/dir/3"
    ]
}
~~~

### How to Use
Just run it in your terminal or schedule it with crontab:
~~~
bash /path/log-clear.sh /path/log-cleaner.json
~~~