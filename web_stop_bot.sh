#!/bin/bash
# Freqtrade Bot Stopper - public_html için

cd /home/dcoakelc/public_html/freqtrade-bot

echo "🛑 Freqtrade Bot durduruluyor..."

# Bot'u durdur
if [ -f "bot.pid" ]; then
    BOT_PID=$(cat bot.pid)
    if ps -p $BOT_PID > /dev/null 2>&1; then
        kill $BOT_PID
        echo "🤖 Bot durduruldu (PID: $BOT_PID)"
    else
        echo "⚠️ Bot zaten çalışmıyor"
    fi
    rm -f bot.pid
fi

# Web UI'ı durdur
if [ -f "webserver.pid" ]; then
    WEB_PID=$(cat webserver.pid)
    if ps -p $WEB_PID > /dev/null 2>&1; then
        kill $WEB_PID
        echo "🌐 Web UI durduruldu (PID: $WEB_PID)"
    else
        echo "⚠️ Web UI zaten çalışmıyor"
    fi
    rm -f webserver.pid
fi

# Durum sayfasını güncelle
echo "<h1>Freqtrade Bot Status</h1>" > status.html
echo "<p>Bot durduruldu: $(date)</p>" >> status.html
echo "<p>Tekrar başlatmak için cron job'ı bekleyin veya manuel başlatın.</p>" >> status.html

echo "✅ Tüm işlemler durduruldu!"
