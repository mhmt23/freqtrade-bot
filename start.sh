#!/bin/bash

# Freqtrade Bot Startup Script for Linux Server
echo "Starting Freqtrade Trading Bot..."

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is required but not installed. Please install Python 3.8 or higher."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install/upgrade requirements
echo "Installing requirements..."
pip install --upgrade pip
pip install -r requirements.txt

# Create necessary directories
mkdir -p logs
mkdir -p user_data/data

# Start the bot
echo "Starting Freqtrade bot..."
nohup python -m freqtrade trade --config config.json --strategy UltraAggressiveScalpingStrategy > logs/bot.log 2>&1 &

# Get the process ID
PID=$!
echo $PID > bot.pid
echo "Bot started with PID: $PID"
echo "Logs: tail -f logs/bot.log"
echo "Web UI: http://YOUR_SERVER_IP:8080"

# Start web server if not running
nohup python -m freqtrade webserver --config config.json > logs/webserver.log 2>&1 &
WEB_PID=$!
echo $WEB_PID > webserver.pid
echo "Web server started with PID: $WEB_PID"

echo "Setup complete! Bot is running in background."
echo "Use ./stop.sh to stop the bot."
