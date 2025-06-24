#!/bin/bash
# FREQTRADE BOT KOMPLE DEPLOYMENT SİSTEMİ
# GitHub: https://github.com/mhmt23/freqtrade-bot
# Otomatik kurulum, bot başlatma ve web monitoring

LOG_FILE="/home/dcoakelc/freqtrade_system.log"
BOT_DIR="/home/dcoakelc/freqtrade-bot"
WEB_DIR="/home/dcoakelc/public_html/freqtrade-bot"
PID_FILE="$BOT_DIR/bot.pid"

echo "========================================" >> $LOG_FILE
echo "$(date): FREQTRADE BOT SİSTEMİ BAŞLADI" >> $LOG_FILE
echo "========================================" >> $LOG_FILE

# Ana dizine git
cd /home/dcoakelc/
echo "$(date): Ana dizin: $(pwd)" >> $LOG_FILE

# Eski bot'u durdur
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "$(date): Eski bot durduruluyor (PID: $OLD_PID)..." >> $LOG_FILE
        kill "$OLD_PID"
        sleep 5
    fi
    rm -f "$PID_FILE"
fi

# Eski dosyaları temizle
echo "$(date): Eski dosyalar temizleniyor..." >> $LOG_FILE
rm -rf "$BOT_DIR" mail freqtrade* bot*

# Repository klonla
echo "$(date): GitHub'dan freqtrade-bot klonlanıyor..." >> $LOG_FILE
git clone https://github.com/mhmt23/freqtrade-bot.git "$BOT_DIR" >> $LOG_FILE 2>&1

if [ ! -d "$BOT_DIR" ]; then
    echo "$(date): HATA: Repository klonlanamadı!" >> $LOG_FILE
    exit 1
fi

cd "$BOT_DIR"
echo "$(date): Bot dizinine geçildi: $(pwd)" >> $LOG_FILE

# Dosyaları listele
echo "$(date): Klonlanan dosyalar:" >> $LOG_FILE
ls -la >> $LOG_FILE

# Python ve pip güncellemesi
echo "$(date): Python paketleri yükleniyor..." >> $LOG_FILE
pip3 install --user --upgrade pip >> $LOG_FILE 2>&1
pip3 install --user freqtrade ccxt pandas numpy ta-lib requests >> $LOG_FILE 2>&1

# Config dosyası kontrolü
if [ -f "config.json" ]; then
    echo "$(date): ✅ Config dosyası bulundu" >> $LOG_FILE
    
    # API anahtarları kontrol et
    if grep -q "YOUR_BINANCE_TESTNET_API_KEY" config.json; then
        echo "$(date): ⚠️ API anahtarları güncellenmemiş!" >> $LOG_FILE
        
        # Varsayılan Binance Testnet API anahtarları ekle (güvenlik için test anahtarları)
        sed -i 's/"YOUR_BINANCE_TESTNET_API_KEY"/"vmPUZE6mv9SD5VNHk4HlWFsOr6aKE2zvsw0MuIgwCIPy6utIco14y7Ju91duEh8A"/g' config.json
        sed -i 's/"YOUR_BINANCE_TESTNET_SECRET_KEY"/"NhqPtmdSJYdKjVHjA7PZj4Mge3R5YNiP1e3UZjInClVN65XAbvqqM6A7H5fATj0j"/g' config.json
        
        echo "$(date): ✅ Test API anahtarları eklendi" >> $LOG_FILE
    fi
else
    echo "$(date): ❌ config.json bulunamadı!" >> $LOG_FILE
    exit 1
fi

# Strategy dosyası kontrolü
if [ -f "UltraAggressiveScalpingStrategy.py" ]; then
    echo "$(date): ✅ Strategy dosyası bulundu" >> $LOG_FILE
else
    echo "$(date): ❌ Strategy dosyası bulunamadı!" >> $LOG_FILE
fi

# İzinleri ayarla
chmod +x *.sh
echo "$(date): Dosya izinleri ayarlandı" >> $LOG_FILE

# Web monitoring klasörünü oluştur
mkdir -p "$WEB_DIR"
echo "$(date): Web monitoring klasörü oluşturuldu: $WEB_DIR" >> $LOG_FILE

# Bot'u başlat
echo "$(date): Freqtrade bot başlatılıyor..." >> $LOG_FILE
nohup python3 -m freqtrade trade \
    --config config.json \
    --strategy UltraAggressiveScalpingStrategy \
    --logfile freqtrade.log \
    > bot_output.log 2>&1 &

BOT_PID=$!
echo $BOT_PID > "$PID_FILE"
echo "$(date): Bot başlatıldı (PID: $BOT_PID)" >> $LOG_FILE

# 5 saniye bekle ve bot durumunu kontrol et
sleep 5
if kill -0 $BOT_PID 2>/dev/null; then
    echo "$(date): ✅ Bot başarıyla çalışıyor!" >> $LOG_FILE
    BOT_STATUS="running"
    BOT_STATUS_MSG="✅ Bot Çalışıyor (PID: $BOT_PID)"
else
    echo "$(date): ❌ Bot başlatılamadı!" >> $LOG_FILE
    BOT_STATUS="failed"
    BOT_STATUS_MSG="❌ Bot Başlatılamadı"
fi

# Web monitoring sayfaları oluştur
echo "$(date): Web monitoring sayfaları oluşturuluyor..." >> $LOG_FILE

# Ana status sayfası
cat > "$WEB_DIR/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Freqtrade Bot Dashboard</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 0; background: #1a1a1a; color: #fff; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 15px; margin-bottom: 30px; text-align: center; }
        .status { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .card { background: #2d2d2d; padding: 25px; border-radius: 15px; border-left: 5px solid #667eea; }
        .running { border-left-color: #28a745; }
        .failed { border-left-color: #dc3545; }
        .warning { border-left-color: #ffc107; }
        .logs { background: #1e1e1e; padding: 20px; border-radius: 15px; font-family: 'Courier New', monospace; font-size: 14px; max-height: 500px; overflow-y: auto; white-space: pre-wrap; }
        .nav { display: flex; gap: 15px; margin-bottom: 30px; flex-wrap: wrap; }
        .nav a { background: #667eea; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; transition: background 0.3s; }
        .nav a:hover { background: #764ba2; }
        .timestamp { color: #888; font-size: 14px; }
        .refresh { position: fixed; top: 20px; right: 20px; background: #28a745; color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; }
    </style>
    <script>
        function refreshPage() { location.reload(); }
        setInterval(refreshPage, 30000); // 30 saniyede bir yenile
        
        function manualRefresh() { location.reload(); }
    </script>
</head>
<body>
    <button class="refresh" onclick="manualRefresh()">🔄 Yenile</button>
    
    <div class="container">
        <div class="header">
            <h1>🤖 Freqtrade Trading Bot</h1>
            <p>Otomatik Kripto Para Trading Sistemi</p>
            <div class="timestamp">Son Güncelleme: $(date)</div>
        </div>
        
        <div class="nav">
            <a href="#status">📊 Durum</a>
            <a href="logs.html">📋 Loglar</a>
            <a href="trades.html">💰 İşlemler</a>
            <a href="config.html">⚙️ Ayarlar</a>
            <a href="http://akelclinics.com:8080" target="_blank">🌐 Web UI</a>
        </div>
        
        <div class="status" id="status">
            <div class="card $BOT_STATUS">
                <h3>🚀 Bot Durumu</h3>
                <p>$BOT_STATUS_MSG</p>
                <p>Başlatma: $(date)</p>
            </div>
            
            <div class="card">
                <h3>📈 Trading Bilgileri</h3>
                <p><strong>Exchange:</strong> Binance Testnet</p>
                <p><strong>Strategy:</strong> UltraAggressiveScalping</p>
                <p><strong>Pairs:</strong> BTC/USDT, ETH/USDT, BNB/USDT</p>
            </div>
            
            <div class="card">
                <h3>🔧 Sistem Bilgileri</h3>
                <p><strong>Repository:</strong> github.com/mhmt23/freqtrade-bot</p>
                <p><strong>Auto-Deploy:</strong> Her 10 dakikada</p>
                <p><strong>Log Dosyası:</strong> /home/dcoakelc/freqtrade_system.log</p>
            </div>
        </div>
        
        <h2>📋 Son Bot Logları</h2>
        <div class="logs" id="logs">
Bot logları yükleniyor...
        </div>
    </div>
</body>
</html>
EOF

# Bot loglarını web sayfasına ekle
if [ -f "freqtrade.log" ]; then
    echo "$(date): Bot logları web sayfasına ekleniyor..." >> $LOG_FILE
    LOG_CONTENT=$(tail -50 freqtrade.log | sed 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g')
    sed -i "s/Bot logları yükleniyor.../$LOG_CONTENT/" "$WEB_DIR/index.html"
fi

# Logs sayfası
cat > "$WEB_DIR/logs.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Freqtrade Bot Logs</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: monospace; margin: 20px; background: #1a1a1a; color: #00ff00; }
        .container { max-width: 1400px; margin: 0 auto; }
        .header { background: #2d2d2d; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .logs { background: #000; padding: 20px; border-radius: 10px; white-space: pre-wrap; 
                max-height: 800px; overflow-y: auto; border: 1px solid #333; }
        .nav { margin-bottom: 20px; }
        .nav a { background: #667eea; color: white; padding: 10px 20px; text-decoration: none; 
                border-radius: 5px; margin-right: 10px; }
    </style>
    <script>
        setInterval(() => location.reload(), 60000); // 1 dakikada bir yenile
    </script>
</head>
<body>
    <div class="container">
        <div class="nav">
            <a href="index.html">← Ana Sayfa</a>
            <a href="#" onclick="location.reload()">🔄 Yenile</a>
        </div>
        
        <div class="header">
            <h1>📋 Freqtrade Bot Logs</h1>
            <p>Son güncelleme: <span id="timestamp"></span> | Auto-refresh: 1 dakikada bir</p>
        </div>
        
        <div class="logs" id="logs">
Loglar yükleniyor...
        </div>
    </div>
    
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString('tr-TR');
    </script>
</body>
</html>
EOF

echo "$(date): ✅ Web monitoring sayfaları oluşturuldu" >> $LOG_FILE

# Son durum raporu
echo "========================================" >> $LOG_FILE
echo "$(date): DEPLOYMENT TAMAMLANDI!" >> $LOG_FILE
echo "📊 Bot Durumu: $BOT_STATUS_MSG" >> $LOG_FILE
echo "🌐 Web Dashboard: http://akelclinics.com/freqtrade-bot/" >> $LOG_FILE
echo "📋 Loglar: http://akelclinics.com/freqtrade-bot/logs.html" >> $LOG_FILE
echo "💻 Web UI: http://akelclinics.com:8080" >> $LOG_FILE
echo "📄 Log Dosyası: $LOG_FILE" >> $LOG_FILE
echo "========================================" >> $LOG_FILE
