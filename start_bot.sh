#!/bin/bash

# Freqtrade Bot Başlatma Scripti
# Linux sunucu için

echo "Freqtrade Bot başlatılıyor..."

# Virtual environment oluştur
if [ ! -d "venv" ]; then
    echo "Virtual environment oluşturuluyor..."
    python3 -m venv venv
fi

# Virtual environment'ı aktifleştir
source venv/bin/activate

# Gerekli paketleri yükle
echo "Bağımlılıklar yükleniyor..."
pip install --upgrade pip
pip install -r requirements.txt

# API anahtarlarını kontrol et
if grep -q "YOUR_API_KEY_HERE" config.json; then
    echo "UYARI: config.json dosyasında API anahtarlarınızı güncelleyin!"
    echo "YOUR_API_KEY_HERE ve YOUR_SECRET_KEY_HERE değerlerini değiştirin."
    exit 1
fi

# Freqtrade'i başlat
echo "Bot başlatılıyor..."
nohup python -m freqtrade trade \
    --config config.json \
    --strategy UltraAggressiveScalpingStrategy \
    --logfile freqtrade.log \
    > /dev/null 2>&1 &

echo "Bot PID: $!"
echo "Bot arka planda çalışıyor."
echo "Logları görmek için: tail -f freqtrade.log"
echo "Web UI: http://$(hostname -I | awk '{print $1}'):8080"

# Process ID'yi kaydet
echo $! > freqtrade.pid

echo "Botu durdurmak için: kill \$(cat freqtrade.pid)"
