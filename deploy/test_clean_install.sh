#!/bin/bash
# TEMİZ FREQTRADE KURULUM TESTİ
# GitHub: https://github.com/mhmt23/freqtrade-bot1

echo "🚀 FREQTRADE BOT TEMİZ KURULUM TESTİ BAŞLADI"
echo "============================================="
echo ""

# Test değişkenleri
REPO_URL="https://github.com/mhmt23/freqtrade-bot1.git"
BOT_DIR="/home/dcoakelc/freqtrade-bot1"
INSTALL_SCRIPT="clean_install.sh"

echo "📋 Test Bilgileri:"
echo "Repository: $REPO_URL"
echo "Bot Directory: $BOT_DIR"
echo "Install Script: $INSTALL_SCRIPT"
echo ""

# 1. Repository erişim testi
echo "1️⃣ Repository erişim testi..."
if curl -s --head https://raw.githubusercontent.com/mhmt23/freqtrade-bot1/master/clean_install.sh | head -n 1 | grep -q "200 OK"; then
    echo "✅ Repository erişilebilir"
else
    echo "❌ Repository erişilemiyor!"
    exit 1
fi

# 2. Script indirme testi
echo ""
echo "2️⃣ Script indirme testi..."
if curl -s -o /tmp/test_clean_install.sh https://raw.githubusercontent.com/mhmt23/freqtrade-bot1/master/clean_install.sh; then
    if [ -f /tmp/test_clean_install.sh ] && [ -s /tmp/test_clean_install.sh ]; then
        echo "✅ Script başarıyla indirildi"
        echo "📄 Script boyutu: $(wc -c < /tmp/test_clean_install.sh) bytes"
    else
        echo "❌ Script indirilemedi!"
        exit 1
    fi
else
    echo "❌ Script indirme başarısız!"
    exit 1
fi

# 3. Script içerik kontrolü
echo ""
echo "3️⃣ Script içerik kontrolü..."
if grep -q "FREQTRADE BOT TEMİZ KURULUM" /tmp/test_clean_install.sh; then
    echo "✅ Script header doğru"
else
    echo "❌ Script header yanlış!"
    exit 1
fi

if grep -q "freqtrade-bot1" /tmp/test_clean_install.sh; then
    echo "✅ Repository URL doğru"
else
    echo "❌ Repository URL yanlış!"
    exit 1
fi

# 4. Python kurulum komutları kontrolü
echo ""
echo "4️⃣ Python kurulum komutları kontrolü..."
if grep -q "pip3 install freqtrade" /tmp/test_clean_install.sh; then
    echo "✅ Freqtrade kurulum komutu var"
else
    echo "❌ Freqtrade kurulum komutu eksik!"
    exit 1
fi

# 5. Config ve strategy dosyaları kontrolü
echo ""
echo "5️⃣ Config ve strategy dosyaları kontrolü..."
if grep -q "config.json" /tmp/test_clean_install.sh; then
    echo "✅ Config dosyası oluşturuluyor"
else
    echo "❌ Config dosyası oluşturulmuyor!"
    exit 1
fi

if grep -q "SimpleScalpingStrategy" /tmp/test_clean_install.sh; then
    echo "✅ Strategy dosyası oluşturuluyor"
else
    echo "❌ Strategy dosyası oluşturulmuyor!"
    exit 1
fi

# 6. Web monitoring kontrolü
echo ""
echo "6️⃣ Web monitoring kontrolü..."
if grep -q "index.html" /tmp/test_clean_install.sh; then
    echo "✅ Web dashboard oluşturuluyor"
else
    echo "❌ Web dashboard oluşturulmuyor!"
    exit 1
fi

# 7. Cron job kontrolü
echo ""
echo "7️⃣ Cron job kontrolü..."
if grep -q "crontab" /tmp/test_clean_install.sh; then
    echo "✅ Cron job ekleniyor"
else
    echo "❌ Cron job eklenmiyor!"
    exit 1
fi

# Temizlik
rm -f /tmp/test_clean_install.sh

echo ""
echo "🎉 TÜM TESTLER BAŞARILI!"
echo "✅ Repository hazır ve kullanılabilir"
echo ""
echo "📥 KURULUM İÇİN ŞUNLARI YAPIN:"
echo ""
echo "1. Sunucuya SSH ile bağlanın:"
echo "   ssh username@akelclinics.com"
echo ""
echo "2. Ana dizine gidin:"
echo "   cd /home/dcoakelc/"
echo ""
echo "3. Eski dosyaları temizleyin:"
echo "   rm -rf freqtrade-bot* bot* mail*"
echo ""
echo "4. Kurulum scriptini indirin:"
echo "   wget https://raw.githubusercontent.com/mhmt23/freqtrade-bot1/master/clean_install.sh"
echo ""
echo "5. Script'i çalıştırılabilir yapın:"
echo "   chmod +x clean_install.sh"
echo ""
echo "6. Kurulumu başlatın:"
echo "   ./clean_install.sh"
echo ""
echo "7. Kurulum loglarını kontrol edin:"
echo "   cat /home/dcoakelc/freqtrade_install.log"
echo ""
echo "8. Web dashboard'ı ziyaret edin:"
echo "   http://akelclinics.com/freqtrade-bot/"
echo ""
echo "============================================="
echo "🤖 FREQTRADE BOT TEMİZ KURULUM HAZIR!"
echo "============================================="
