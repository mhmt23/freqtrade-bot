#!/bin/bash
# Freqtrade Bot Starter - public_html için
# Web üzerinden erişilebilir loglar ile

cd /home/dcoakelc/public_html/freqtrade-bot

# Bot zaten çalışıyor mu kontrol et
if [ -f "bot.pid" ] && ps -p $(cat bot.pid) > /dev/null 2>&1; then
    echo "⚠️ Bot zaten çalışıyor. PID: $(cat bot.pid)"
    exit 0
fi

# Gerekli dizinleri oluştur
mkdir -p logs

# Bot'u başlat
echo "🚀 Freqtrade Bot başlatılıyor..."
nohup python3 -m freqtrade trade --config config.json --strategy UltraAggressiveScalpingStrategy > freqtrade.log 2>&1 &

# PID'yi kaydet
BOT_PID=$!
echo $BOT_PID > bot.pid

# Web UI'ı başlat (farklı port)
nohup python3 -m freqtrade webserver --config config.json > webserver.log 2>&1 &
WEB_PID=$!
echo $WEB_PID > webserver.pid

echo "✅ Bot başlatıldı!"
echo "🤖 Bot PID: $BOT_PID" 
echo "🌐 Web UI PID: $WEB_PID"
echo "📊 Durum: http://akelclinics.com/freqtrade-bot/status.html"
echo "🌐 Web UI: http://akelclinics.com:8080"

# İlk durum raporunu oluştur
sleep 5
echo "<h1>Freqtrade Bot Status</h1>" > status.html
echo "<p>Bot başlatıldı: $(date)</p>" >> status.html
echo "<p>Bot PID: $BOT_PID</p>" >> status.html
echo "<p>Web UI PID: $WEB_PID</p>" >> status.html
echo "<h2>Son Loglar:</h2>" >> status.html
echo "<pre>" >> status.html
tail -50 freqtrade.log >> status.html
echo "</pre>" >> status.html
echo "<p><a href='http://akelclinics.com:8080'>Web UI'a Git</a></p>" >> status.html
