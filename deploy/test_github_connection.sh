#!/bin/bash
# GitHub Bağlantı Testi ve Repository Kontrolü
# Test script for GitHub connectivity and repository access

echo "🔍 GitHub Bağlantı Testi Başlatılıyor..."
echo "========================================"

# Repository URL
REPO_URL="https://github.com/mhmt23/freqtrade-bot1.git"
echo "📍 Test edilecek repository: $REPO_URL"

# Internet bağlantısı kontrolü
echo -n "🌐 Internet bağlantısı kontrol ediliyor... "
if ping -c 1 google.com > /dev/null 2>&1; then
    echo "✅ Bağlantı var"
else
    echo "❌ Internet bağlantısı yok!"
    exit 1
fi

# GitHub bağlantısı kontrolü
echo -n "🐙 GitHub'a bağlantı kontrol ediliyor... "
if ping -c 1 github.com > /dev/null 2>&1; then
    echo "✅ GitHub erişilebilir"
else
    echo "❌ GitHub'a erişilemiyor!"
    exit 1
fi

# Repository erişim kontrolü
echo -n "📁 Repository erişim kontrol ediliyor... "
if curl -s --head "$REPO_URL" | head -n 1 | grep -q "200 OK"; then
    echo "✅ Repository erişilebilir"
else
    echo "❌ Repository'e erişilemiyor!"
    exit 1
fi

# Git kurulu mu kontrol et
echo -n "⚙️ Git kurulumu kontrol ediliyor... "
if command -v git > /dev/null 2>&1; then
    echo "✅ Git kurulu ($(git --version))"
else
    echo "❌ Git kurulu değil!"
    echo "Git kurulumu gerekli: yum install git veya apt-get install git"
    exit 1
fi

# Test klonlama
echo "🔄 Test klonlama başlatılıyor..."
TEST_DIR="/tmp/freqtrade-test-$$"
if git clone "$REPO_URL" "$TEST_DIR" > /dev/null 2>&1; then
    echo "✅ Repository başarıyla klonlandı"
    
    # Klonlanan dosyaları kontrol et
    echo "📋 Klonlanan dosyalar:"
    ls -la "$TEST_DIR/deploy/" | head -10
    
    # Gerekli dosyaları kontrol et
    if [ -f "$TEST_DIR/deploy/clean_install.sh" ]; then
        echo "✅ clean_install.sh bulundu"
    else
        echo "❌ clean_install.sh bulunamadı!"
    fi
    
    if [ -f "$TEST_DIR/deploy/config.json" ]; then
        echo "✅ config.json bulundu"
    else
        echo "❌ config.json bulunamadı!"
    fi
    
    if [ -f "$TEST_DIR/deploy/SimpleScalpingStrategy.py" ]; then
        echo "✅ SimpleScalpingStrategy.py bulundu"
    else
        echo "❌ SimpleScalpingStrategy.py bulunamadı!"
    fi
    
    # Test dizinini temizle
    rm -rf "$TEST_DIR"
    echo "🧹 Test dizini temizlendi"
    
else
    echo "❌ Repository klonlanamadı!"
    echo "Muhtemel nedenler:"
    echo "- Repository private olabilir"
    echo "- Network/firewall sorunu"
    echo "- SSH key eksik olabilir"
    exit 1
fi

echo ""
echo "🎉 Tüm testler başarılı!"
echo "✅ GitHub repository'ye erişim var"
echo "✅ Gerekli dosyalar repository'de mevcut"
echo "✅ Klonlama işlemi çalışıyor"
echo ""
echo "🚀 clean_install.sh script'ini çalıştırabilirsiniz:"
echo "curl -O https://raw.githubusercontent.com/mhmt23/freqtrade-bot1/master/deploy/clean_install.sh"
echo "chmod +x clean_install.sh"
echo "./clean_install.sh"
