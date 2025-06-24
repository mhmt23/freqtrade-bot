#!/bin/bash
# GitHub'dan otomatik deployment scripti
# Bu script sunucuda çalıştırılır ve GitHub'dan son değişiklikleri çeker

echo "🚀 GitHub'dan Freqtrade Bot güncelleniyor..."

# Ana dizine git
cd /home/dcoakelc/

# Eğer bot klasörü yoksa klonla
if [ ! -d "freqtrade-bot" ]; then
    echo "📥 Repository klonlanıyor..."
    git clone https://github.com/mhmt23/freqtrade-bot.git
    cd freqtrade-bot
else
    echo "🔄 Mevcut repository güncelleniyor..."
    cd freqtrade-bot
    
    # Bot'u durdur (eğer çalışıyorsa)
    if [ -f bot.pid ]; then
        echo "⏹️ Bot durduruluyor..."
        kill $(cat bot.pid) 2>/dev/null
        rm -f bot.pid
    fi
    
    # GitHub'dan son değişiklikleri çek
    git fetch origin
    git reset --hard origin/master
    echo "✅ Kod güncellendi"
fi

# İzinleri ayarla
chmod +x *.sh

# Python paketlerini güncelle
echo "📦 Python paketleri kontrol ediliyor..."
pip3 install --user --upgrade freqtrade ccxt pandas numpy

# Config dosyasını kontrol et
if [ ! -f config.json ]; then
    echo "❌ config.json bulunamadı!"
    exit 1
fi

# API anahtarlarını kontrol et
if grep -q "YOUR_BINANCE_TESTNET_API_KEY" config.json; then
    echo "⚠️ API anahtarlarını güncelleyin!"
    echo "nano config.json komutu ile düzenleyin"
    exit 1
fi

# Bot'u başlat
echo "🎯 Bot başlatılıyor..."
nohup python3 -m freqtrade trade --config config.json --strategy UltraAggressiveScalpingStrategy > freqtrade.log 2>&1 &
echo $! > bot.pid

echo "✅ Deployment tamamlandı!"
echo "PID: $(cat bot.pid)"
echo "Log: tail -f freqtrade.log"
echo "Web UI: http://akelclinics.com:8080"
