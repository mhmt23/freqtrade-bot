#!/bin/bash
# ADIM 1: Temel sistem testi

echo "========== ADIM 1: TEMEL TEST =========="
echo "Tarih: $(date)"
echo "Kullanıcı: $(whoami)"
echo "Ana dizin: $HOME"
echo "Mevcut dizin: $(pwd)"

# Test dosyası oluştur
echo "Test dosyası oluşturuluyor..."
echo "Bu bir test dosyasıdır. Oluşturulma: $(date)" > /home/dcoakelc/test_success.txt

if [ -f "/home/dcoakelc/test_success.txt" ]; then
    echo "✅ Dosya oluşturma başarılı!"
else
    echo "❌ Dosya oluşturma başarısız!"
fi

# Git kontrol
if command -v git &> /dev/null; then
    echo "✅ Git mevcut: $(git --version)"
else
    echo "❌ Git bulunamadı!"
fi

# Python kontrol
if command -v python3 &> /dev/null; then
    echo "✅ Python3 mevcut: $(python3 --version)"
else
    echo "❌ Python3 bulunamadı!"
fi

# İnternet kontrol
if ping -c 1 google.com &> /dev/null; then
    echo "✅ İnternet bağlantısı var"
else
    echo "❌ İnternet bağlantısı yok!"
fi

echo "========== TEST TAMAMLANDI =========="
