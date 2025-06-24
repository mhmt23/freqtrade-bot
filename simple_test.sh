#!/bin/bash
# Basit test scripti
echo "$(date): Auto-deploy başlatıldı" >> /home/dcoakelc/test.log

# Ana dizine git
cd /home/dcoakelc/

# Git kurulu mu kontrol et
if ! command -v git &> /dev/null; then
    echo "$(date): Git bulunamadı!" >> test.log
    exit 1
fi

# Freqtrade bot klasörü var mı?
if [ ! -d "freqtrade-bot" ]; then
    echo "$(date): Repository klonlanıyor..." >> test.log
    git clone https://github.com/mhmt23/freqtrade-bot.git >> test.log 2>&1
    
    if [ $? -eq 0 ]; then
        echo "$(date): Repository başarıyla klonlandı" >> test.log
    else
        echo "$(date): Repository klonlama HATASI!" >> test.log
        exit 1
    fi
else
    echo "$(date): Repository zaten var, güncelleniyor..." >> test.log
    cd freqtrade-bot
    git pull origin develop >> /home/dcoakelc/test.log 2>&1
    cd ..
fi

echo "$(date): İşlem tamamlandı!" >> test.log

# Test sayfası oluştur
mkdir -p /home/dcoakelc/public_html/freqtrade-test
echo "<h1>Test: $(date)</h1><p>Auto-deploy çalışıyor!</p>" > /home/dcoakelc/public_html/freqtrade-test/index.html

echo "$(date): Test sayfası oluşturuldu" >> test.log
