#!/bin/bash
# GitHub'dan otomatik deployment scripti - Doğru path ile düzeltilmiş
# Bu script sunucuda çalıştırılır ve GitHub'dan son değişiklikleri çeker

echo "🚀 GitHub'dan Freqtrade Bot güncelleniyor..."

# Ana dizine git (doğru path)
cd /home/dcoakelc/

# Eğer bot klasörü yoksa klonla
if [ ! -d "freqtrade-bot" ]; then
    echo "📥 Repository klonlanıyor..."
    git clone https://github.com/mhmt23/freqtrade-bot.git
    cd freqtrade-bot
else
    echo "🔄 Mevcut repository güncelleniyor..."
    cd freqtrade-bot
    
    # Bot'u durdur (eğer çalışıyorsa)
    if [ -f bot.pid ]; then
        echo "⏹️ Bot durduruluyor..."
        kill $(cat bot.pid) 2>/dev/null
        rm -f bot.pid
    fi
    
    # GitHub'dan son değişiklikleri çek
    git fetch origin
    git reset --hard origin/master
    echo "✅ Kod güncellendi"
fi

# İzinleri ayarla
chmod +x *.sh

# Python paketlerini güncelle
echo "📦 Python paketleri kontrol ediliyor..."
pip3 install --user --upgrade freqtrade ccxt pandas numpy

# Config dosyasını kontrol et
if [ ! -f config.json ]; then
    echo "❌ config.json bulunamadı!"
    exit 1
fi

# API anahtarlarını kontrol et
if grep -q "YOUR_BINANCE_TESTNET_API_KEY" config.json; then
    echo "⚠️ API anahtarlarını güncelleyin!"
    echo "nano config.json komutu ile düzenleyin"
    exit 1
fi

# Web deployment klasörünü oluştur
echo "🌐 Web deployment klasörü oluşturuluyor..."
WEB_DIR="/home/dcoakelc/public_html/freqtrade-bot"
mkdir -p "$WEB_DIR"

# Status ve log sayfalarını oluştur
cat > "$WEB_DIR/status.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Freqtrade Bot Status</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f0f0f0; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
        .status { padding: 10px; margin: 10px 0; border-radius: 5px; }
        .running { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .stopped { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        pre { background: #f8f9fa; padding: 10px; border-radius: 5px; overflow-x: auto; }
    </style>
    <script>
        function refreshPage() { location.reload(); }
        setInterval(refreshPage, 30000); // 30 saniyede bir yenile
    </script>
</head>
<body>
    <div class="container">
        <h1>🤖 Freqtrade Bot Status</h1>
        <div class="info">
            <strong>Son Güncelleme:</strong> <span id="timestamp"></span><br>
            <strong>Auto-refresh:</strong> 30 saniyede bir
        </div>
        <div id="status-content">
            <div class="status running">
                <strong>✅ Bot Durumu:</strong> Başlatılıyor...
            </div>
        </div>
        <h2>📊 Hızlı Linkler</h2>
        <a href="logs.html">📋 Bot Logları</a> | 
        <a href="http://akelclinics.com:8080">🌐 Web UI</a>
    </div>
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString('tr-TR');
    </script>
</body>
</html>
EOF

cat > "$WEB_DIR/logs.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Freqtrade Bot Logs</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: monospace; margin: 20px; background: #1e1e1e; color: #f0f0f0; }
        .container { max-width: 1200px; margin: 0 auto; }
        .log-box { background: #2d2d2d; padding: 15px; border-radius: 5px; white-space: pre-wrap; 
                   max-height: 600px; overflow-y: auto; border: 1px solid #444; }
        .header { background: #333; color: white; padding: 10px; border-radius: 5px; margin-bottom: 20px; }
        a { color: #4dabf7; }
    </style>
    <script>
        function refreshPage() { location.reload(); }
        setInterval(refreshPage, 60000); // 1 dakikada bir yenile
    </script>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📋 Freqtrade Bot Logs</h1>
            <p>Son Güncelleme: <span id="timestamp"></span> | Auto-refresh: 1 dakikada bir</p>
            <a href="status.html">← Status Sayfasına Dön</a>
        </div>
        <div class="log-box" id="logs">
            Bot logları yükleniyor...
        </div>
    </div>
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString('tr-TR');
    </script>
</body>
</html>
EOF

# Bot'u başlat
echo "🎯 Bot başlatılıyor..."
nohup python3 -m freqtrade trade --config config.json --strategy UltraAggressiveScalpingStrategy > freqtrade.log 2>&1 &
echo $! > bot.pid

# Status sayfasını güncelle
if [ -f bot.pid ]; then
    BOT_PID=$(cat bot.pid)
    if kill -0 $BOT_PID 2>/dev/null; then
        STATUS="running"
        STATUS_MSG="✅ Bot Çalışıyor (PID: $BOT_PID)"
    else
        STATUS="stopped"
        STATUS_MSG="❌ Bot Durmuş"
    fi
else
    STATUS="stopped"
    STATUS_MSG="❌ Bot PID dosyası bulunamadı"
fi

# Log dosyasının son 100 satırını web sayfasına koy
if [ -f freqtrade.log ]; then
    tail -100 freqtrade.log > "$WEB_DIR/latest_logs.txt"
    # Logs.html'i gerçek loglarla güncelle
    sed -i "s/Bot logları yükleniyor.../$(tail -50 freqtrade.log | sed 's/&/\\&/g;s/</\\&lt;/g;s/>/\\&gt;/g' | tr '\n' '\\n')/g" "$WEB_DIR/logs.html" 2>/dev/null || true
fi

echo "✅ Deployment tamamlandı!"
echo "📊 Status: $STATUS_MSG"
echo "📋 Log: tail -f freqtrade.log"
echo "🌐 Web Status: http://akelclinics.com/freqtrade-bot/status.html"
echo "📋 Web Logs: http://akelclinics.com/freqtrade-bot/logs.html"
echo "💻 Web UI: http://akelclinics.com:8080"

# Deployment zamanını logla
echo "$(date): Deployment completed - Status: $STATUS" >> deployment.log
