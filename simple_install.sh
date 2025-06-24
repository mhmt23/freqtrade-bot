#!/bin/bash
cd /home/dcoakelc/
mkdir -p freqtrade-bot
cd freqtrade-bot
wget -O config.json https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/config.json
wget -O UltraAggressiveScalpingStrategy.py https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/UltraAggressiveScalpingStrategy.py
wget -O requirements.txt https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/requirements.txt
wget -O start_bot.sh https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/start_bot.sh
chmod +x *.sh
pip3 install --user freqtrade ccxt pandas numpy
echo "Kurulum tamamlandi. config.json'da API anahtarlarinizi guncelleyin."
