#!/bin/bash
# FREQTRADE BOT LOKAL DEPLOYMENT SİSTEMİ
# Manuel dosya yükleme ile çalışır - GitHub'a bağımlı değil
# Dosyaları önce /home/dcoakelc/bot_files/ klasörüne yükleyin

LOG_FILE="/home/dcoakelc/freqtrade_install.log"
BOT_DIR="/home/dcoakelc/freqtrade-bot1"
UPLOAD_DIR="/home/dcoakelc/bot_files"
PID_FILE="$BOT_DIR/bot.pid"

echo "========================================" >> $LOG_FILE
echo "$(date): FREQTRADE BOT LOKAL KURULUM BAŞLADI" >> $LOG_FILE
echo "========================================" >> $LOG_FILE

# Ana dizine git
cd /home/dcoakelc/
echo "$(date): Ana dizin: $(pwd)" >> $LOG_FILE

# Upload klasörü kontrol et
if [ ! -d "$UPLOAD_DIR" ]; then
    echo "$(date): ❌ HATA: $UPLOAD_DIR klasörü bulunamadı!" >> $LOG_FILE
    echo "$(date): Lütfen bot dosyalarını $UPLOAD_DIR klasörüne yükleyin" >> $LOG_FILE
    echo ""
    echo "Gerekli dosyalar:"
    echo "- config.json"
    echo "- SimpleScalpingStrategy.py"
    echo "- requirements_simple.txt"
    echo "- Bu script dosyası"
    exit 1
fi

echo "$(date): ✅ Upload klasörü bulundu: $UPLOAD_DIR" >> $LOG_FILE

# Gerekli dosyaları kontrol et
REQUIRED_FILES=("config.json" "SimpleScalpingStrategy.py" "requirements_simple.txt")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$UPLOAD_DIR/$file" ]; then
        echo "$(date): ❌ HATA: $file dosyası $UPLOAD_DIR klasöründe bulunamadı!" >> $LOG_FILE
        exit 1
    else
        echo "$(date): ✅ $file dosyası bulundu" >> $LOG_FILE
    fi
done

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
rm -rf "$BOT_DIR" freqtrade* bot*

# Bot dizinini oluştur
mkdir -p "$BOT_DIR"
echo "$(date): Bot dizini oluşturuldu: $BOT_DIR" >> $LOG_FILE

# Dosyaları kopyala
echo "$(date): Bot dosyaları kopyalanıyor..." >> $LOG_FILE
cp "$UPLOAD_DIR"/* "$BOT_DIR/"
cd "$BOT_DIR"

# Dosya izinlerini ayarla
chmod +x *.sh 2>/dev/null || true
chmod 644 *.py *.json *.txt 2>/dev/null || true

# Dosyaları listele
echo "$(date): Kopyalanan dosyalar:" >> $LOG_FILE
ls -la >> $LOG_FILE

# Python ve pip güncellemesi
echo "$(date): Python paketleri yükleniyor..." >> $LOG_FILE
pip3 install --user --upgrade pip >> $LOG_FILE 2>&1

# Requirements dosyasından paket kurulumu
if [ -f "requirements_simple.txt" ]; then
    echo "$(date): Requirements.txt'den paketler yükleniyor..." >> $LOG_FILE
    pip3 install --user -r requirements_simple.txt >> $LOG_FILE 2>&1
else
    echo "$(date): Varsayılan paketler yükleniyor..." >> $LOG_FILE
    pip3 install --user freqtrade ccxt pandas numpy requests >> $LOG_FILE 2>&1
fi

# Config dosyası kontrolü ve düzenleme
if [ -f "config.json" ]; then
    echo "$(date): ✅ Config dosyası bulundu" >> $LOG_FILE
    
    # API anahtarları kontrol et
    if grep -q "YOUR_BINANCE_TESTNET_API_KEY" config.json; then
        echo "$(date): ⚠️ API anahtarları güncellenmemiş!" >> $LOG_FILE
        
        # Varsayılan Binance Testnet API anahtarları ekle
        sed -i 's/"YOUR_BINANCE_TESTNET_API_KEY"/"vmPUZE6mv9SD5VNHk4HlWFsOr6aKE2zvsw0MuIgwCIPy6utIco14y7Ju91duEh8A"/g' config.json
        sed -i 's/"YOUR_BINANCE_TESTNET_SECRET_KEY"/"NhqPtmdSJYdKjVHjA7PZj4Mge3R5YNiP1e3UZjInClVN65XAbvqqM6A7H5fATj0j"/g' config.json
        
        echo "$(date): ✅ Test API anahtarları eklendi" >> $LOG_FILE
    fi
else
    echo "$(date): ❌ config.json bulunamadı!" >> $LOG_FILE
    exit 1
fi

# Strategy dosyası kontrolü
STRATEGY_FILE=""
if [ -f "SimpleScalpingStrategy.py" ]; then
    STRATEGY_FILE="SimpleScalpingStrategy"
    echo "$(date): ✅ SimpleScalpingStrategy.py bulundu" >> $LOG_FILE
elif [ -f "UltraAggressiveScalpingStrategy.py" ]; then
    STRATEGY_FILE="UltraAggressiveScalpingStrategy"
    echo "$(date): ✅ UltraAggressiveScalpingStrategy.py bulundu" >> $LOG_FILE
else
    echo "$(date): ❌ Strategy dosyası bulunamadı!" >> $LOG_FILE
    exit 1
fi

# Web monitoring klasörünü kontrol et ve oluştur
if [ -d "/home/dcoakelc/public_html" ] && [ "$(ls -A /home/dcoakelc/public_html)" ]; then
    # public_html dolu ise alt klasör kullan
    WEB_DIR="/home/dcoakelc/public_html/freqtrade-bot"
    WEB_URL="http://akelclinics.com/freqtrade-bot/"
    echo "$(date): public_html dolu, alt klasör kullanılıyor: $WEB_DIR" >> $LOG_FILE
else
    # public_html boş ise doğrudan ana domain'i kullan
    WEB_DIR="/home/dcoakelc/public_html"
    WEB_URL="http://akelclinics.com/"
    echo "$(date): public_html boş, ana domain kullanılıyor: $WEB_DIR" >> $LOG_FILE
fi

mkdir -p "$WEB_DIR"
echo "$(date): Web monitoring klasörü hazırlandı: $WEB_DIR" >> $LOG_FILE

# Bot'u başlat
echo "$(date): Freqtrade bot başlatılıyor..." >> $LOG_FILE
nohup python3 -m freqtrade trade \
    --config config.json \
    --strategy "$STRATEGY_FILE" \
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
    
    # Hata detaylarını logla
    echo "$(date): Bot output logları:" >> $LOG_FILE
    if [ -f "bot_output.log" ]; then
        tail -20 bot_output.log >> $LOG_FILE
    fi
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
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 0; background: #0a0a0a; color: #00ff41; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .header { 
            background: linear-gradient(45deg, #001100, #003300); 
            padding: 30px; border-radius: 15px; margin-bottom: 30px; text-align: center;
            border: 1px solid #00ff41; box-shadow: 0 0 20px rgba(0, 255, 65, 0.3);
        }
        .status { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .card { 
            background: #111; padding: 25px; border-radius: 15px; 
            border: 1px solid #00aa00; box-shadow: 0 0 10px rgba(0, 255, 65, 0.1);
        }
        .running { border-color: #00ff41; box-shadow: 0 0 15px rgba(0, 255, 65, 0.3); }
        .failed { border-color: #ff0000; color: #ff6666; box-shadow: 0 0 15px rgba(255, 0, 0, 0.3); }
        .warning { border-color: #ffaa00; color: #ffcc66; }
        .logs { 
            background: #000; padding: 20px; border-radius: 15px; 
            font-family: 'Courier New', monospace; font-size: 14px; 
            max-height: 500px; overflow-y: auto; white-space: pre-wrap;
            border: 1px solid #00aa00; color: #00ff41;
        }
        .nav { display: flex; gap: 15px; margin-bottom: 30px; flex-wrap: wrap; }
        .nav a { 
            background: linear-gradient(45deg, #003300, #005500); 
            color: #00ff41; padding: 12px 24px; text-decoration: none; 
            border-radius: 8px; transition: all 0.3s;
            border: 1px solid #00aa00;
        }
        .nav a:hover { box-shadow: 0 0 10px rgba(0, 255, 65, 0.5); }
        .timestamp { color: #888; font-size: 14px; }
        .refresh { 
            position: fixed; top: 20px; right: 20px; 
            background: #00aa00; color: #fff; border: none; 
            padding: 10px 20px; border-radius: 8px; cursor: pointer;
            border: 1px solid #00ff41;
        }
        h1, h2, h3 { color: #00ff41; text-shadow: 0 0 5px rgba(0, 255, 65, 0.5); }
        .matrix-effect {
            animation: matrix 2s infinite;
        }
        @keyframes matrix {
            0% { text-shadow: 0 0 5px #00ff41; }
            50% { text-shadow: 0 0 20px #00ff41, 0 0 30px #00ff41; }
            100% { text-shadow: 0 0 5px #00ff41; }
        }
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
            <h1 class="matrix-effect">🤖 Freqtrade Trading Bot</h1>
            <p>Otomatik Kripto Para Trading Sistemi</p>
            <div class="timestamp">Son Güncelleme: $(date)</div>
        </div>
        
        <div class="nav">
            <a href="#status">📊 Durum</a>
            <a href="logs.html">📋 Loglar</a>
            <a href="status.php">⚡ Canlı Status</a>
            <a href="#config">⚙️ Ayarlar</a>
        </div>
        
        <div class="status" id="status">
            <div class="card $BOT_STATUS">
                <h3>🚀 Bot Durumu</h3>
                <p>$BOT_STATUS_MSG</p>
                <p>Başlatma: $(date)</p>
                <p>Strategy: $STRATEGY_FILE</p>
            </div>
            
            <div class="card">
                <h3>📈 Trading Bilgileri</h3>
                <p><strong>Exchange:</strong> Binance Testnet</p>
                <p><strong>Strategy:</strong> $STRATEGY_FILE</p>
                <p><strong>Pairs:</strong> BTC/USDT, ETH/USDT, BNB/USDT</p>
                <p><strong>Deployment:</strong> Manuel Upload</p>
            </div>
            
            <div class="card">
                <h3>🔧 Sistem Bilgileri</h3>
                <p><strong>Kurulum:</strong> Lokal Dosya Sistemi</p>
                <p><strong>Bot Dizini:</strong> $BOT_DIR</p>
                <p><strong>Upload Dizini:</strong> $UPLOAD_DIR</p>
                <p><strong>Log Dosyası:</strong> $LOG_FILE</p>
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
    LOG_CONTENT=$(tail -30 freqtrade.log | sed 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g')
    sed -i "s/Bot logları yükleniyor.../$LOG_CONTENT/" "$WEB_DIR/index.html"
fi

# Logs sayfası
cat > "$WEB_DIR/logs.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Freqtrade Bot Logs - Matrix Style</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { 
            font-family: 'Courier New', monospace; margin: 0; padding: 20px;
            background: #000; color: #00ff41; overflow-x: hidden;
        }
        .container { max-width: 1400px; margin: 0 auto; }
        .header { 
            background: linear-gradient(45deg, #001100, #003300); 
            padding: 20px; border-radius: 10px; margin-bottom: 20px;
            border: 1px solid #00ff41; text-align: center;
        }
        .logs { 
            background: #000; padding: 20px; border-radius: 10px; 
            white-space: pre-wrap; max-height: 800px; overflow-y: auto; 
            border: 2px solid #00aa00; font-size: 13px; line-height: 1.4;
            box-shadow: inset 0 0 20px rgba(0, 255, 65, 0.1);
        }
        .nav { margin-bottom: 20px; text-align: center; }
        .nav a { 
            background: linear-gradient(45deg, #003300, #005500); 
            color: #00ff41; padding: 10px 20px; text-decoration: none; 
            border-radius: 5px; margin-right: 10px;
            border: 1px solid #00aa00; display: inline-block;
        }
        .nav a:hover { box-shadow: 0 0 15px rgba(0, 255, 65, 0.5); }
        h1 { 
            color: #00ff41; text-shadow: 0 0 10px #00ff41;
            animation: glow 2s ease-in-out infinite alternate;
        }
        @keyframes glow {
            from { text-shadow: 0 0 10px #00ff41; }
            to { text-shadow: 0 0 20px #00ff41, 0 0 30px #00ff41; }
        }
        .matrix-line {
            animation: matrix-scroll 0.1s linear;
        }
        @keyframes matrix-scroll {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
    <script>
        function refreshLogs() {
            location.reload();
        }
        setInterval(refreshLogs, 60000); // 1 dakikada bir yenile
        
        // Matrix effect for new lines
        function addMatrixEffect() {
            const logs = document.getElementById('logs');
            const lines = logs.innerHTML.split('\n');
            logs.innerHTML = lines.map(line => 
                `<div class="matrix-line">${line}</div>`
            ).join('');
        }
        
        window.onload = addMatrixEffect;
    </script>
</head>
<body>
    <div class="container">
        <div class="nav">
            <a href="index.html">← Ana Sayfa</a>
            <a href="#" onclick="refreshLogs()">🔄 Yenile</a>
            <a href="status.php">⚡ Canlı Status</a>
        </div>
        
        <div class="header">
            <h1>📋 Freqtrade Bot Logs - Matrix Interface</h1>
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

# PHP status sayfası
cat > "$WEB_DIR/status.php" << 'EOF'
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$botDir = '/home/dcoakelc/freqtrade-bot1';
$pidFile = $botDir . '/bot.pid';
$logFile = '/home/dcoakelc/freqtrade_install.log';
$freqtradeLog = $botDir . '/freqtrade.log';

$status = array(
    'timestamp' => date('Y-m-d H:i:s'),
    'bot_running' => false,
    'pid' => null,
    'last_log_lines' => array(),
    'freqtrade_logs' => array(),
    'uptime' => 'Unknown'
);

// PID kontrolü
if (file_exists($pidFile)) {
    $pid = trim(file_get_contents($pidFile));
    if ($pid && is_numeric($pid)) {
        $status['pid'] = $pid;
        // Process çalışıyor mu kontrol et
        $running = shell_exec("ps -p $pid > /dev/null 2>&1; echo $?");
        $status['bot_running'] = (trim($running) === '0');
    }
}

// Log dosyası varsa son satırları al
if (file_exists($logFile)) {
    $lines = file($logFile);
    $status['last_log_lines'] = array_slice($lines, -10);
}

// Freqtrade logları
if (file_exists($freqtradeLog)) {
    $lines = file($freqtradeLog);
    $status['freqtrade_logs'] = array_slice($lines, -20);
}

echo json_encode($status, JSON_PRETTY_PRINT);
?>
EOF

echo "$(date): ✅ Web monitoring sayfaları oluşturuldu" >> $LOG_FILE

# Bot restart scripti oluştur
cat > "$BOT_DIR/restart_bot.sh" << EOF
#!/bin/bash
# Bot Restart Script
echo "\$(date): Bot restart başlatılıyor..." >> $LOG_FILE
cd $BOT_DIR
if [ -f "$PID_FILE" ]; then
    OLD_PID=\$(cat "$PID_FILE")
    if kill -0 "\$OLD_PID" 2>/dev/null; then
        kill "\$OLD_PID"
        sleep 3
    fi
fi

nohup python3 -m freqtrade trade \\
    --config config.json \\
    --strategy "$STRATEGY_FILE" \\
    --logfile freqtrade.log \\
    > bot_output.log 2>&1 &

echo \$! > "$PID_FILE"
echo "\$(date): Bot yeniden başlatıldı (PID: \$!)" >> $LOG_FILE
EOF

chmod +x "$BOT_DIR/restart_bot.sh"
echo "$(date): ✅ Restart scripti oluşturuldu" >> $LOG_FILE

# Son durum raporu
echo "========================================" >> $LOG_FILE
echo "$(date): LOKAL DEPLOYMENT TAMAMLANDI!" >> $LOG_FILE
echo "📊 Bot Durumu: $BOT_STATUS_MSG" >> $LOG_FILE
echo "🌐 Web Dashboard: $WEB_URL" >> $LOG_FILE
echo "📋 Loglar: ${WEB_URL}logs.html" >> $LOG_FILE
echo "⚡ Canlı Status: ${WEB_URL}status.php" >> $LOG_FILE
echo "📁 Bot Dizini: $BOT_DIR" >> $LOG_FILE
echo "📁 Upload Dizini: $UPLOAD_DIR" >> $LOG_FILE
echo "📄 Log Dosyası: $LOG_FILE" >> $LOG_FILE
echo "🔄 Restart: $BOT_DIR/restart_bot.sh" >> $LOG_FILE
echo "========================================" >> $LOG_FILE

# Sonuç ekrana yazdır
echo ""
echo "🎉 Freqtrade Bot Kurulumu Tamamlandı!"
echo "=================================="
echo "📊 Bot Durumu: $BOT_STATUS_MSG"
echo "🌐 Web Dashboard: $WEB_URL"
echo "📋 Loglar: ${WEB_URL}logs.html"
echo "⚡ Canlı Status: ${WEB_URL}status.php"
echo "📄 Kurulum Logları: $LOG_FILE"
echo ""
if [ "$BOT_STATUS" = "failed" ]; then
    echo "❌ Bot başlatılamadı! Loglara bakın:"
    echo "tail -50 $LOG_FILE"
    echo "tail -20 $BOT_DIR/bot_output.log"
fi
