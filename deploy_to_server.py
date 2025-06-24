#!/usr/bin/env python3
"""
Sunucuya deployment script'i
cPanel sunucusuna Freqtrade bot'u kurmak için
"""

import os
import sys

def print_deployment_instructions():
    """Deployment talimatlarını yazdır"""
    
    print("""
🚀 FREQTRADE BOT SUNUCU DEPLOYMENT TALIMATLARI
==============================================

Adım 1: cPanel'e giriş yapın
---------------------------
Panel Adresi: http://93.89.225.129:2082
Kullanıcı: dcoakelc
Şifre: 8[vH8}lL

Adım 2: Terminal/SSH Erişimi
---------------------------
cPanel'de "Terminal" veya "SSH Access" bölümünü bulun
Terminal'e bağlanın

Adım 3: Python kontrolü
----------------------
python3 --version
pip3 --version

(Eğer yoksa: yum install python3 python3-pip)

Adım 4: Bot'u indirin
--------------------
cd /home/dcoakelc/
git clone https://github.com/mhmt23/freqtrade-bot.git
cd freqtrade-bot

Adım 5: Gereksinimler
--------------------
pip3 install --user -r requirements.txt

Adım 6: İzinleri ayarlayın
-------------------------
chmod +x start_bot.sh
chmod +x stop_bot.sh

Adım 7: API anahtarlarını güncelleyin
-----------------------------------
nano config.json
(Binance Testnet API key/secret'larınızı girin)

Adım 8: Bot'u başlatın
---------------------
./start_bot.sh

Adım 9: Durumu kontrol edin
--------------------------
ps aux | grep freqtrade
cat freqtrade.log

Adım 10: Web UI (isteğe bağlı)
-----------------------------
Eğer web UI istiyorsanız:
- cPanel'de port 8080'i açın
- Firewall ayarlarından 8080'i izin verin
- http://akelclinics.com:8080 adresinden erişin

YARDIMCI KOMUTLAR:
------------------
Bot'u durdurmak: ./stop_bot.sh
Bot'u yeniden başlatmak: ./stop_bot.sh && ./start_bot.sh
Log'ları görmek: tail -f freqtrade.log
Bot'u güncellemek: git pull origin master

NOT:
----
- Bu Testnet modu, gerçek para kullanmıyor
- 24/7 çalışacak şekilde ayarlanmış
- Loglar freqtrade.log dosyasına yazılıyor
- Herhangi bir sorun durumunda bot otomatik yeniden başlayacak

🎯 GitHub Repository: https://github.com/mhmt23/freqtrade-bot
    """)

def create_simple_installer():
    """Basit installer script oluştur"""
    
    installer_content = """#!/bin/bash
# Freqtrade Bot Otomatik Kurulum
echo "🚀 Freqtrade Bot Kurulumu Başlıyor..."

# Gerekli paketleri kontrol et
echo "📦 Python kontrolü..."
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 bulunamadı. Yükleniyor..."
    sudo yum install -y python3 python3-pip
fi

echo "📁 Bot dosyalarını indiriliyor..."
cd /home/dcoakelc/
rm -rf freqtrade-bot
git clone https://github.com/mhmt23/freqtrade-bot.git
cd freqtrade-bot

echo "📦 Python paketleri yükleniyor..."
pip3 install --user -r requirements.txt

echo "🔧 İzinler ayarlanıyor..."
chmod +x *.sh

echo "✅ Kurulum tamamlandı!"
echo ""
echo "Şimdi yapılacaklar:"
echo "1. nano config.json - API anahtarlarınızı girin"
echo "2. ./start_bot.sh - Bot'u başlatın"
echo "3. tail -f freqtrade.log - Logları izleyin"
"""
    
    with open('install.sh', 'w') as f:
        f.write(installer_content)
    
    print("✅ install.sh dosyası oluşturuldu")

if __name__ == "__main__":
    print_deployment_instructions()
    create_simple_installer()
