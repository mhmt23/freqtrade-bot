#!/usr/bin/env python3
"""
cPanel API ile Freqtrade Bot deployment scripti
SSH olmadan direkt cPanel üzerinden kurulum yapar
"""

import requests
import json
import base64
import time

# cPanel API bilgileri
CPANEL_HOST = "93.89.225.129"
CPANEL_PORT = "2082"
CPANEL_USER = "dcoakelc"
API_TOKEN = "WBWN62ZOOIZTW297WH38IUDBRG4SM2NQ"

class CPanelAPI:
    def __init__(self, host, port, user, token):
        self.host = host
        self.port = port
        self.user = user
        self.token = token
        self.base_url = f"http://{host}:{port}"
        
    def _make_request(self, endpoint, params=None):
        """cPanel API isteği yap"""
        url = f"{self.base_url}{endpoint}"
        headers = {
            'Authorization': f'cpanel {self.user}:{self.token}',
            'Content-Type': 'application/x-www-form-urlencoded'
        }
        
        try:
            response = requests.get(url, headers=headers, params=params, timeout=30)
            return response.json()
        except Exception as e:
            print(f"❌ API hatası: {e}")
            return None
    
    def create_file(self, filepath, content):
        """Dosya oluştur"""
        endpoint = "/execute/Fileman/save_file_content"
        params = {
            'file': filepath,
            'content': content,
            'encoding': 'utf-8'
        }
        return self._make_request(endpoint, params)
    
    def run_command(self, command):
        """Terminal komutu çalıştır (eğer destekleniyorsa)"""
        endpoint = "/execute/Terminal/exec"
        params = {
            'command': command
        }
        return self._make_request(endpoint, params)

def deploy_bot():
    """Bot'u cPanel'e deploy et"""
    
    print("🚀 cPanel API ile Freqtrade Bot Deployment")
    print("=" * 50)
    
    api = CPanelAPI(CPANEL_HOST, CPANEL_PORT, CPANEL_USER, API_TOKEN)
    
    # Kurulum scripti oluştur
    install_script = """#!/bin/bash
# Freqtrade Bot Kurulum Scripti
echo "🚀 Freqtrade Bot kurulumu başlıyor..."

# Ana dizine git
cd /home/dcoakelc/

# Python kontrolü
if ! command -v python3 &> /dev/null; then
    echo "Python3 kuruluyor..."
    # Shared hosting'de genellikle Python3 zaten kurulu
fi

# Gerekli dizinleri oluştur
mkdir -p freqtrade-bot
cd freqtrade-bot

# GitHub'dan dosyaları indir (wget ile)
echo "📥 Bot dosyaları indiriliyor..."

# Ana config dosyası
wget -O config.json https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/config.json

# Strategy dosyası  
wget -O UltraAggressiveScalpingStrategy.py https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/UltraAggressiveScalpingStrategy.py

# Requirements
wget -O requirements.txt https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/requirements.txt

# Start/Stop scriptleri
wget -O start_bot.sh https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/start_bot.sh
wget -O stop_bot.sh https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/stop_bot.sh

# İzinleri ayarla
chmod +x *.sh

# Gerekli Python paketlerini yükle
echo "📦 Python paketleri yükleniyor..."
pip3 install --user freqtrade ccxt pandas numpy

echo "✅ Kurulum tamamlandı!"
echo "Şimdi config.json'da API anahtarlarınızı güncelleyin"
echo "Sonra ./start_bot.sh ile bot'u başlatın"
"""
    
    # Basit start scripti
    start_script = """#!/bin/bash
cd /home/dcoakelc/freqtrade-bot
nohup python3 -m freqtrade trade --config config.json --strategy UltraAggressiveScalpingStrategy > freqtrade.log 2>&1 &
echo $! > bot.pid
echo "Bot başlatıldı. PID: $(cat bot.pid)"
echo "Log: tail -f freqtrade.log"
"""
    
    # Stop scripti
    stop_script = """#!/bin/bash
cd /home/dcoakelc/freqtrade-bot
if [ -f bot.pid ]; then
    kill $(cat bot.pid)
    rm bot.pid
    echo "Bot durduruldu"
else
    echo "Bot PID dosyası bulunamadı"
fi
"""
    
    print("📁 Dosyalar cPanel'e yükleniyor...")
    
    # Dosyaları oluştur
    files_to_create = {
        '/home/dcoakelc/install_freqtrade.sh': install_script,
        '/home/dcoakelc/start_freqtrade.sh': start_script,
        '/home/dcoakelc/stop_freqtrade.sh': stop_script
    }
    
    for filepath, content in files_to_create.items():
        print(f"📄 Oluşturuluyor: {filepath}")
        result = api.create_file(filepath, content)
        if result:
            print(f"✅ {filepath} oluşturuldu")
        else:
            print(f"❌ {filepath} oluşturulamadı")
    
    print("\n🎉 DEPLOYMENT TAMAMLANDI!")
    print("=" * 50)
    print("\nŞimdi cPanel File Manager'dan şu adımları takip edin:")
    print("\n1. File Manager'ı açın")
    print("2. /home/dcoakelc/ dizinine gidin")
    print("3. install_freqtrade.sh dosyasına sağ tıklayın")
    print("4. 'Change Permissions' -> 755 yapın")
    print("5. Terminal'de veya cPanel'de şu komutu çalıştırın:")
    print("   ./install_freqtrade.sh")
    print("\n6. Kurulum bitince config.json'da API anahtarlarınızı güncelleyin")
    print("7. ./start_freqtrade.sh ile bot'u başlatın")
    
    print(f"\n📊 GitHub Repository: https://github.com/mhmt23/freqtrade-bot")
    print(f"🌐 Potansiyel Web UI: http://akelclinics.com:8080")

if __name__ == "__main__":
    deploy_bot()
