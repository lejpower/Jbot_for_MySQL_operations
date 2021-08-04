#!/bin/bash
################
# made by Uijun
# DATE : 2016/01/13
################
source /home/uijun.lee/.nodebrew/env/bot_env.sh

export PATH="node_modules/.bin:node_modules/hubot/node_modules/.bin:$PATH"
export CURRENT_USER=`echo $USER`
export HOME_DIR="/home/${CURRENT_USER}"
export CURRENT_DIR=`pwd`
export HUBOT_ADAPTER="hipchat"
export HUBOT_HIPCHAT_TOKEN=${HIPCHAT_TOKEN}
export HUBOT_HIPCHAT_JID=${HIPCHAT_JID}
export HUBOT_HIPCHAT_PASSWORD=${HIPCHAT_PASSWORD}
export HUBOT_HIPCHAT_ROOMS="${CHAT_ROOM_NAME}"
#export HUBOT_LOG_LEVEL=debug

case "$1" in
    start)
        set -e
        npm install
        forever start -c coffee node_modules/.bin/hubot --name "uijun_bot" "$@"
        #forever start -c coffee ${CURRENT_DIR}/node_modules/.bin/hubot --name "uijun_bot" "$@"
        echo ""
        echo "------->"
        echo "Running Hubot"
        ;;
    stop)
        forever stop -c coffee node_modules/.bin/hubot
        #forever stop -c coffee ${CURRENT_DIR}/node_modules/.bin/hubot
        echo ""
        echo "------->"
        echo "Stopping Hubot"
        ;;
    cleanlog)
        ls -l ${HOME_DIR}/.forever/*.log
        ${HOME_DIR}/.nodebrew/current/bin/forever cleanlogs
        echo ""
        echo "### forever clean log ###"
        echo ""
        ls -l ${HOME_DIR}/.forever/*.log
        ;;
    status)
        echo "### forever status ###"
        ${HOME_DIR}/.nodebrew/current/bin/forever list
        echo ""
        echo ""
        echo "### ps status ###"
        ps -ef | grep hubot | egrep -v "grep|start_hubot"
        ;;
    *)
        echo "Usage: $0 {start|stop|status|cleanlog}"
        exit 1
esac
exit 0
