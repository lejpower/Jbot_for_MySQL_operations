# Jbot

Jbot is a chat bot built on the [Hubot][hubot] framework. 

You should set environment setting in "/home/uijun.lee/.nodebrew/env/bot_env.sh"
```
PATH="node_modules/.bin:node_modules/hubot/node_modules/.bin:$PATH"
CURRENT_USER=`echo $USER`
HOME_DIR="/home/${CURRENT_USER}"
CURRENT_DIR=`pwd`
HUBOT_ADAPTER="hipchat"
HUBOT_HIPCHAT_TOKEN=${HIPCHAT_TOKEN}
HUBOT_HIPCHAT_JID=${HIPCHAT_JID}
HUBOT_HIPCHAT_PASSWORD=${HIPCHAT_PASSWORD}
HUBOT_HIPCHAT_ROOMS="${CHAT_ROOM_NAME}"
```

You can start Jbot locally using a start_script:

    % ./start_hubot.sh [start | stop | cleanlog | status]

