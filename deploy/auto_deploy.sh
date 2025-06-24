#!/bin/bash
# GitHub'dan otomatik deployment scripti - Geliştirilmiş versiyon
# Log dosyası ile hata takibi

LOG_FILE="/home/dcoakelc/deploy.log"
echo "$(date): Deployment başladı" >> $LOG_FILE

# Ana dizine git
cd /home/dcoakelc/
echo "$(date): Ana dizine geçildi: $(pwd)" >> $LOG_FILE

# Eski klasörü temizle ve yeniden klonla (her zaman en güncel hali için)
if [ -d "freqtrade-bot" ]; then
    echo "$(date): Eski klasör siliniyor..." >> $LOG_FILE
    rm -rf freqtrade-bot
fi

# Repository'yi klonla
echo "$(date): Repository klonlanıyor..." >> $LOG_FILE
git clone https://github.com/mhmt23/freqtrade-bot.git >> $LOG_FILE 2>&1

if [ -d "freqtrade-bot" ]; then
    echo "$(date): Repository başarıyla klonlandı" >> $LOG_FILE
    cd freqtrade-bot
    echo "$(date): Bot klasörüne geçildi: $(pwd)" >> $LOG_FILE
    
    # Dosyaları listele
    echo "$(date): Klonlanan dosyalar:" >> $LOG_FILE
    ls -la >> $LOG_FILE
else
    echo "$(date): HATA: Repository klonlanamadı!" >> $LOG_FILE
    exit 1
fi

# İzinleri ayarla
chmod +x *.sh
echo "$(date): Dosya izinleri ayarlandı" >> $LOG_FILE

# Config dosyası var mı kontrol et
if [ -f "config.json" ]; then
    echo "$(date): Config dosyası bulundu" >> $LOG_FILE
else
    echo "$(date): UYARI: config.json bulunamadı!" >> $LOG_FILE
fi

# Strategy dosyası var mı kontrol et
if [ -f "UltraAggressiveScalpingStrategy.py" ]; then
    echo "$(date): Strategy dosyası bulundu" >> $LOG_FILE
else
    echo "$(date): UYARI: Strategy dosyası bulunamadı!" >> $LOG_FILE
fi

# Web klasörünü oluştur
WEB_DIR="/home/dcoakelc/public_html/freqtrade-bot"
mkdir -p "$WEB_DIR"
echo "$(date): Web klasörü oluşturuldu: $WEB_DIR" >> $LOG_FILE

# Basit status sayfası oluştur
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
    </style>
</head>
<body>
    <div class="container">
        <h1>🤖 Freqtrade Bot</h1>
        <div class="status">
            <strong>✅ Bot kurulumu tamamlandı!</strong><br>
            Son güncelleme: TIMESTAMP
        </div>
        <p><strong>Repository:</strong> github.com/mhmt23/freqtrade-bot</p>
        <p><strong>Log dosyası:</strong> /home/dcoakelc/deploy.log</p>
    </div>
</body>
</html>
EOF

# Timestamp'i güncelle
sed -i "s/TIMESTAMP/$(date)/" "$WEB_DIR/index.html"
echo "$(date): Status sayfası oluşturuldu" >> $LOG_FILE

echo "$(date): Deployment tamamlandı!" >> $LOG_FILE
echo "$(date): Web adresi: http://akelclinics.com/freqtrade-bot/" >> $LOG_FILE
echo "$(date): Log dosyası: $LOG_FILE" >> $LOG_FILE
