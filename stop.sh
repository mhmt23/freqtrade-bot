#!/bin/bash

# Freqtrade Bot Stop Script
echo "Stopping Freqtrade Trading Bot..."

# Stop the bot if running
if [ -f "bot.pid" ]; then
    BOT_PID=$(cat bot.pid)
    if ps -p $BOT_PID > /dev/null; then
        echo "Stopping bot (PID: $BOT_PID)..."
        kill $BOT_PID
        rm bot.pid
        echo "Bot stopped."
    else
        echo "Bot is not running."
        rm bot.pid
    fi
else
    echo "No bot PID file found."
fi

# Stop the web server if running
if [ -f "webserver.pid" ]; then
    WEB_PID=$(cat webserver.pid)
    if ps -p $WEB_PID > /dev/null; then
        echo "Stopping web server (PID: $WEB_PID)..."
        kill $WEB_PID
        rm webserver.pid
        echo "Web server stopped."
    else
        echo "Web server is not running."
        rm webserver.pid
    fi
else
    echo "No web server PID file found."
fi

echo "All processes stopped."
