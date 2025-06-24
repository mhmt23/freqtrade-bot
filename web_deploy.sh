#!/bin/bash
# Freqtrade Bot - GitHub Otomatik Deployment Script
# akelclinics.com/public_html için optimize edilmiş

echo "🚀 GitHub'dan Freqtrade Bot güncelleniyor..."
echo "================================================"

# Web root dizinine git
cd /home/dcoakelc/public_html/

# Bot klasörü oluştur (eğer yoksa)
if [ ! -d "freqtrade-bot" ]; then
    echo "📁 Bot klasörü oluşturuluyor..."
    mkdir -p freqtrade-bot
fi

cd freqtrade-bot

# Eğer git repository yoksa klonla
if [ ! -d ".git" ]; then
    echo "📥 GitHub repository klonlanıyor..."
    rm -rf *
    git clone https://github.com/mhmt23/freqtrade-bot.git .
else
    echo "🔄 GitHub'dan güncellemeler çekiliyor..."
    git fetch origin
    git reset --hard origin/master
fi

# Python paketlerini yükle
echo "📦 Python paketleri kontrol ediliyor..."
pip3 install --user freqtrade ccxt pandas numpy requests

# İzinleri ayarla
chmod +x *.sh 2>/dev/null

# Bot çalışıyor mu kontrol et
if [ -f "bot.pid" ] && ps -p $(cat bot.pid) > /dev/null 2>&1; then
    echo "🔄 Bot yeniden başlatılıyor..."
    ./stop_bot.sh
    sleep 2
    ./start_bot.sh
else
    echo "▶️ Bot başlatılıyor..."
    ./start_bot.sh
fi

# Web server için log dosyası oluştur
echo "📊 Log dosyası web erişimi için hazırlanıyor..."
if [ -f "freqtrade.log" ]; then
    # Son 100 satırı web'de görülebilir yap
    tail -100 freqtrade.log > status.txt
    echo "<pre>$(cat status.txt)</pre>" > status.html
fi

echo "✅ Deployment tamamlandı!"
echo "📊 Bot durumu: http://akelclinics.com/freqtrade-bot/status.html"
echo "🌐 Web UI: http://akelclinics.com:8080"
echo "📝 Loglar: /home/dcoakelc/public_html/freqtrade-bot/freqtrade.log"
