#!/bin/bash

# Freqtrade Bot Durdurma Scripti

echo "Freqtrade Bot durduruluyor..."

if [ -f "freqtrade.pid" ]; then
    PID=$(cat freqtrade.pid)
    if ps -p $PID > /dev/null; then
        kill $PID
        echo "Bot durduruldu (PID: $PID)"
        rm freqtrade.pid
    else
        echo "Bot zaten durmuş."
        rm freqtrade.pid
    fi
else
    # PID dosyası yoksa process ismine göre bul
    pkill -f "freqtrade trade"
    echo "Tüm freqtrade processleri durduruldu."
fi

echo "Bot durduruldu."
