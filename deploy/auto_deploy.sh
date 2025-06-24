#!/bin/bash
# GitHub'dan otomatik deployment scripti - Klasör adı düzeltilmiş
# Log dosyası ile hata takibi

LOG_FILE="/home/dcoakelc/deploy.log"
echo "$(date): Deployment başladı" >> $LOG_FILE

# Ana dizine git
cd /home/dcoakelc/
echo "$(date): Ana dizine geçildi: $(pwd)" >> $LOG_FILE

# Eski klasörleri temizle
echo "$(date): Eski klasörler temizleniyor..." >> $LOG_FILE
rm -rf freqtrade-bot mail freqtrade* bot*

# Repository'yi klonla - belirli klasör adı ile
echo "$(date): Repository klonlanıyor..." >> $LOG_FILE
git clone https://github.com/mhmt23/freqtrade-bot.git freqtrade-bot >> $LOG_FILE 2>&1

if [ -d "freqtrade-bot" ]; then
    echo "$(date): Repository başarıyla klonlandı: freqtrade-bot" >> $LOG_FILE
    cd freqtrade-bot
    echo "$(date): Bot klasörüne geçildi: $(pwd)" >> $LOG_FILE
    
    # Dosyaları listele
    echo "$(date): Klonlanan dosyalar:" >> $LOG_FILE
    ls -la >> $LOG_FILE
    
    # Dosya kontrolleri
    if [ -f "config.json" ]; then
        echo "$(date): ✅ Config dosyası bulundu" >> $LOG_FILE
    else
        echo "$(date): ❌ config.json bulunamadı!" >> $LOG_FILE
    fi
    
    if [ -f "UltraAggressiveScalpingStrategy.py" ]; then
        echo "$(date): ✅ Strategy dosyası bulundu" >> $LOG_FILE
    else
        echo "$(date): ❌ Strategy dosyası bulunamadı!" >> $LOG_FILE
    fi
    
    # Web klasörünü oluştur
    WEB_DIR="/home/dcoakelc/public_html/freqtrade-bot"
    mkdir -p "$WEB_DIR"
    echo "$(date): Web klasörü oluşturuldu: $WEB_DIR" >> $LOG_FILE
    
    # Status sayfası oluştur
    cat > "$WEB_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Freqtrade Bot Status</title>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f0f0f0; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
        .status { padding: 15px; margin: 10px 0; border-radius: 5px; background: #d4edda; color: #155724; }
        .file { background: #e2e3e5; padding: 5px; margin: 2px 0; border-radius: 3px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🤖 Freqtrade Bot Status</h1>
        <div class="status">
            <strong>✅ Bot kurulumu tamamlandı!</strong><br>
            Son güncelleme: TIMESTAMP
        </div>
        <h2>📂 Klonlanan Dosyalar:</h2>
        <div id="files">FILELIST</div>
        <p><strong>Repository:</strong> github.com/mhmt23/freqtrade-bot</p>
        <p><strong>Log dosyası:</strong> /home/dcoakelc/deploy.log</p>
    </div>
</body>
</html>
EOF
    
    # Dosya listesini ekle
    FILE_LIST=$(ls -la | head -20 | sed 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g' | sed 's/^/<div class="file">/' | sed 's/$/<\/div>/')
    sed -i "s/FILELIST/$FILE_LIST/" "$WEB_DIR/index.html"
    sed -i "s/TIMESTAMP/$(date)/" "$WEB_DIR/index.html"
    
    echo "$(date): ✅ Status sayfası oluşturuldu" >> $LOG_FILE
    
else
    echo "$(date): ❌ HATA: Repository klonlanamadı!" >> $LOG_FILE
    exit 1
fi

echo "$(date): 🎉 Deployment tamamlandı!" >> $LOG_FILE
echo "$(date): 🌐 Web adresi: http://akelclinics.com/freqtrade-bot/" >> $LOG_FILE
echo "$(date): 📋 Log dosyası: $LOG_FILE" >> $LOG_FILE
