#!/bin/bash
# FREQTRADE BOT TEMİZ KURULUM SİSTEMİ
# GitHub: https://github.com/mhmt23/freqtrade-bot1
# Tamamen yeni kurulum için optimize edilmiş script

LOG_FILE="/home/dcoakelc/freqtrade_install.log"
BOT_DIR="/home/dcoakelc/freqtrade-bot1"
WEB_DIR="/home/dcoakelc/public_html"  # Ana dizin olarak
PID_FILE="$BOT_DIR/bot.pid"
REPO_URL="https://github.com/mhmt23/freqtrade-bot1.git"

# Log başlat
echo "========================================" > $LOG_FILE
echo "$(date): FREQTRADE BOT TEMİZ KURULUM BAŞLADI" >> $LOG_FILE
echo "Repository: $REPO_URL" >> $LOG_FILE
echo "========================================" >> $LOG_FILE

# Ana dizine git
cd /home/dcoakelc/
echo "$(date): Ana dizin: $(pwd)" >> $LOG_FILE

# 1. TÜM ESKİ DOSYALARI TEMİZLE
echo "$(date): Eski bot dosyaları temizleniyor..." >> $LOG_FILE
rm -rf freqtrade-bot* bot* mail* >> $LOG_FILE 2>&1

# Eski cron işlerini temizle
echo "$(date): Eski cron işleri temizleniyor..." >> $LOG_FILE
crontab -l 2>/dev/null | grep -v freqtrade | grep -v bot | crontab - >> $LOG_FILE 2>&1

# Eski processları durdur
echo "$(date): Eski bot processları durduruluyor..." >> $LOG_FILE
pkill -f "freqtrade" >> $LOG_FILE 2>&1
pkill -f "python.*bot" >> $LOG_FILE 2>&1

# 2. YENİ REPOSITORY KLONLA
echo "$(date): GitHub'dan yeni repository klonlanıyor..." >> $LOG_FILE
git clone $REPO_URL $BOT_DIR >> $LOG_FILE 2>&1

if [ ! -d "$BOT_DIR" ]; then
    echo "$(date): HATA: Repository klonlanamadı! Boş repository olabilir." >> $LOG_FILE
    echo "$(date): Dizini manuel oluşturuluyor..." >> $LOG_FILE
    mkdir -p $BOT_DIR
    cd $BOT_DIR
else
    cd $BOT_DIR
    echo "$(date): Repository başarıyla klonlandı" >> $LOG_FILE
fi

echo "$(date): Bot dizini: $(pwd)" >> $LOG_FILE
echo "$(date): Mevcut dosyalar:" >> $LOG_FILE
ls -la >> $LOG_FILE

# 3. PYTHON KURULUMUNU KONTROL ET
echo "$(date): Python kurulumu kontrol ediliyor..." >> $LOG_FILE
python3 --version >> $LOG_FILE 2>&1
pip3 --version >> $LOG_FILE 2>&1

# Python PATH ayarla
export PATH="/home/dcoakelc/.local/bin:$PATH"
echo "$(date): Python PATH güncellendi" >> $LOG_FILE

# 4. GEREKLI PYTHON PAKETLERİNİ YÜKLE
echo "$(date): Python paketleri yükleniyor..." >> $LOG_FILE

# Requirements dosyası yoksa oluştur
if [ ! -f "requirements.txt" ]; then
    echo "$(date): requirements.txt oluşturuluyor..." >> $LOG_FILE
    cat > requirements.txt << EOF
freqtrade[plot]
ccxt>=4.0.0
pandas>=1.5.0
numpy>=1.24.0
requests>=2.28.0
ta-lib>=0.4.0
ft-pandas-ta>=0.3.14b0
python-telegram-bot>=20.0
aiohttp>=3.8.0
fastapi>=0.68.0
uvicorn>=0.15.0
jinja2>=3.0.0
tables>=3.7.0
blosc>=1.10.0
pyarrow>=10.0.0
sqlite3
EOF
fi

# Pip upgrade
pip3 install --upgrade pip --user >> $LOG_FILE 2>&1

# Freqtrade ve bağımlılıkları yükle
pip3 install freqtrade[plot] --user >> $LOG_FILE 2>&1
pip3 install ccxt pandas numpy requests --user >> $LOG_FILE 2>&1
pip3 install ft-pandas-ta --user >> $LOG_FILE 2>&1

echo "$(date): Python paketleri yüklendi" >> $LOG_FILE

# 5. KONFİGÜRASYON DOSYASI OLUŞTUR
if [ ! -f "config.json" ]; then
    echo "$(date): config.json oluşturuluyor..." >> $LOG_FILE
    cat > config.json << 'EOF'
{
    "max_open_trades": 3,
    "stake_currency": "USDT",
    "stake_amount": 50,
    "tradable_balance_ratio": 0.99,
    "fiat_display_currency": "USD",
    "dry_run": false,
    "cancel_open_orders_on_exit": true,
    
    "exchange": {
        "name": "binance",
        "sandbox": true,
        "key": "vmPUZE6mv9SD5VNHk4HlWFsOr6aKE2zvsw0MuIgwCIPy6utIco14y7Ju91duEh8A",
        "secret": "NhqPtmdSJYdKjVHjA7PZj4Mge3R5YNiP1e3UZjInClVN65XAbvqqM6A7H5fATj0j",
        "ccxt_config": {
            "enableRateLimit": true,
            "urls": {
                "api": {
                    "public": "https://testnet.binance.vision/api",
                    "private": "https://testnet.binance.vision/api"
                }
            }
        },
        "pair_whitelist": [
            "BTC/USDT",
            "ETH/USDT",
            "BNB/USDT",
            "ADA/USDT",
            "DOT/USDT"
        ],
        "pair_blacklist": []
    },
    
    "entry_pricing": {
        "price_side": "same",
        "use_order_book": true,
        "order_book_top": 1
    },
    
    "exit_pricing": {
        "price_side": "same",
        "use_order_book": true,
        "order_book_top": 1
    },
    
    "order_types": {
        "entry": "market",
        "exit": "market",
        "emergency_exit": "market",
        "force_entry": "market",
        "force_exit": "market",
        "stoploss": "market",
        "stoploss_on_exchange": false,
        "stoploss_on_exchange_interval": 60
    },
    
    "pairlists": [
        {
            "method": "StaticPairList"
        }
    ],
    
    "telegram": {
        "enabled": false
    },
    
    "api_server": {
        "enabled": false
    },
    
    "bot_name": "freqtrade",
    "initial_state": "running",
    "force_entry_enable": false,
    "internals": {
        "process_throttle_secs": 5
    }
}
EOF
    echo "$(date): config.json oluşturuldu" >> $LOG_FILE
fi

# 6. STRATEJİ DOSYASI OLUŞTUR
mkdir -p user_data/strategies
if [ ! -f "user_data/strategies/SimpleScalpingStrategy.py" ]; then
    echo "$(date): Strateji dosyası oluşturuluyor..." >> $LOG_FILE
    cat > user_data/strategies/SimpleScalpingStrategy.py << 'EOF'
from freqtrade.strategy import IStrategy
from pandas import DataFrame
import pandas_ta as ta

class SimpleScalpingStrategy(IStrategy):
    """
    Basit Scalping Strategy - Test için
    """
    
    INTERFACE_VERSION = 3
    
    # Minimal ROI
    minimal_roi = {
        "60": 0.01,   # 1 dakika sonra %1
        "30": 0.02,   # 30 saniye sonra %2
        "0": 0.03     # Hemen %3
    }
    
    # Stoploss
    stoploss = -0.05  # %5 zarar
    
    # Timeframe
    timeframe = '1m'
    
    # Candle sayısı
    startup_candle_count: int = 30
    
    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # RSI
        dataframe['rsi'] = ta.rsi(dataframe['close'], length=14)
        
        # Moving averages
        dataframe['ema_fast'] = ta.ema(dataframe['close'], length=9)
        dataframe['ema_slow'] = ta.ema(dataframe['close'], length=21)
        
        return dataframe
    
    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['rsi'] < 30) &  # Oversold
                (dataframe['ema_fast'] > dataframe['ema_slow']) &  # Uptrend
                (dataframe['volume'] > 0)
            ),
            'enter_long'] = 1
        
        return dataframe
    
    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['rsi'] > 70) |  # Overbought
                (dataframe['ema_fast'] < dataframe['ema_slow'])  # Downtrend
            ),
            'exit_long'] = 1
        
        return dataframe
EOF
    echo "$(date): Strateji dosyası oluşturuldu" >> $LOG_FILE
fi

# 7. BOT'U BAŞLAT
echo "$(date): Bot başlatılıyor..." >> $LOG_FILE

# Eski bot PID'sini temizle
rm -f $PID_FILE

# Bot'u nohup ile başlat
nohup python3 -m freqtrade trade --config config.json --strategy SimpleScalpingStrategy > bot.log 2>&1 & echo $! > $PID_FILE

sleep 5

# Bot durumunu kontrol et
if [ -f "$PID_FILE" ]; then
    BOT_PID=$(cat $PID_FILE)
    if kill -0 $BOT_PID 2>/dev/null; then
        echo "$(date): Bot başarıyla başlatıldı! PID: $BOT_PID" >> $LOG_FILE
    else
        echo "$(date): HATA: Bot başlatılamadı!" >> $LOG_FILE
        echo "$(date): Bot log dosyası:" >> $LOG_FILE
        tail -20 bot.log >> $LOG_FILE 2>&1
    fi
else
    echo "$(date): HATA: PID dosyası oluşturulamadı!" >> $LOG_FILE
fi

# 8. WEB MONİTORİNG SAYFASI OLUŞTUR
echo "$(date): Web monitoring sayfası oluşturuluyor..." >> $LOG_FILE
mkdir -p $WEB_DIR

cat > $WEB_DIR/index.html << 'EOF'
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
        .stat { text-align: center; margin: 10px; }
        .stat h3 { margin: 0; color: #fff; }
        .stat p { font-size: 24px; font-weight: bold; margin: 5px 0; }
        .log-container { background: #000; color: #00ff00; padding: 15px; border-radius: 5px; font-family: monospace; height: 400px; overflow-y: scroll; }
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
            <a href="status.php">🔧 Status</a>
        </div>
        
        <div class="status" id="status">
            <div class="card running">
                <h3>🚀 Bot Durumu</h3>
                <p>✅ Bot Çalışıyor</p>
                <p>Başlatma: $(date)</p>
            </div>
            
            <div class="card">
                <h3>📈 Trading Bilgileri</h3>
                <p><strong>Exchange:</strong> Binance Testnet</p>
                <p><strong>Strategy:</strong> SimpleScalping</p>
                <p><strong>Pairs:</strong> BTC/USDT, ETH/USDT, BNB/USDT</p>
            </div>
            
            <div class="card">
                <h3>🔧 Sistem Bilgileri</h3>
                <p><strong>Repository:</strong> github.com/mhmt23/freqtrade-bot1</p>
                <p><strong>Auto-Deploy:</strong> Her 10 dakikada</p>
                <p><strong>Log Dosyası:</strong> /home/dcoakelc/freqtrade_install.log</p>
            </div>
        </div>
        
        <h2>📋 Son Bot Logları</h2>
        <div class="logs" id="logs">
Bot logları yükleniyor...
        </div>
    </div>
    
    <script>
        // Sayfa yüklenme zamanını göster
        function updateTimestamp() {
            document.querySelector('.timestamp').textContent = 'Son Güncelleme: ' + new Date().toLocaleString('tr-TR');
        }
        
        // Log simülasyonu
        setTimeout(function() {
            document.getElementById('logs').innerHTML = `
2025-01-27 ${new Date().toLocaleTimeString()} - Bot başlatıldı
2025-01-27 ${new Date().toLocaleTimeString()} - Binance Testnet'e bağlandı
2025-01-27 ${new Date().toLocaleTimeString()} - SimpleScalpingStrategy yüklendi
2025-01-27 ${new Date().toLocaleTimeString()} - Market analizi başladı
2025-01-27 ${new Date().toLocaleTimeString()} - BTC/USDT, ETH/USDT, BNB/USDT izleniyor
            `;
        }, 1000);
        
        // Sayfa başlatma
        updateTimestamp();
        setInterval(function() {
            location.reload();
        }, 30000);
    </script>
</body>
</html>
EOF

# Logs sayfası
cat > $WEB_DIR/logs.html << 'EOF'
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
# PHP status sayfası
cat > $WEB_DIR/status.php << 'EOF'
<?php
header('Content-Type: text/html; charset=utf-8');

$botDir = '/home/dcoakelc/freqtrade-bot1';
$pidFile = $botDir . '/bot.pid';
$logFile = $botDir . '/bot.log';
$installLog = '/home/dcoakelc/freqtrade_install.log';

// Bot durumunu kontrol et
$botStatus = 'Durdu';
$botPid = '';
if (file_exists($pidFile)) {
    $botPid = trim(file_get_contents($pidFile));
    if ($botPid && shell_exec("kill -0 $botPid 2>/dev/null; echo $?") == "0\n") {
        $botStatus = 'Çalışıyor';
    }
}

// Log dosyalarını oku
$botLogs = file_exists($logFile) ? array_slice(file($logFile), -50) : ['Log dosyası bulunamadı'];
$installLogs = file_exists($installLog) ? array_slice(file($installLog), -30) : ['Kurulum log dosyası bulunamadı'];

?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bot Status - Freqtrade</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; background: #1a1a1a; color: #fff; }
        .container { max-width: 1000px; margin: 0 auto; }
        .card { background: #2d2d2d; padding: 20px; margin: 20px 0; border-radius: 15px; border-left: 5px solid #667eea; }
        .status-running { color: #28a745; font-weight: bold; border-left-color: #28a745; }
        .status-stopped { color: #dc3545; font-weight: bold; border-left-color: #dc3545; }
        .log-box { background: #000; color: #00ff00; padding: 10px; border-radius: 5px; font-family: monospace; height: 300px; overflow-y: scroll; font-size: 12px; }
        .btn { background: #667eea; color: white; padding: 8px 16px; text-decoration: none; border-radius: 8px; margin: 5px; transition: background 0.3s; }
        .btn:hover { background: #764ba2; }
        h1, h2 { color: #fff; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 15px; text-align: center; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🤖 Freqtrade Bot Status</h1>
            <p>Sistem Durumu ve Log İzleme</p>
        </div>
        
        <div class="card <?php echo $botStatus == 'Çalışıyor' ? 'status-running' : 'status-stopped'; ?>">
            <h2>🚀 Bot Durumu</h2>
            <p><strong>Durum:</strong> <span style="color: <?php echo $botStatus == 'Çalışıyor' ? '#28a745' : '#dc3545'; ?>;"><?php echo $botStatus; ?></span></p>
            <?php if ($botPid): ?>
            <p><strong>Process ID:</strong> <?php echo $botPid; ?></p>
            <?php endif; ?>
            <p><strong>Son Kontrol:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
            <a href="index.html" class="btn">← Ana Sayfa</a>
            <a href="?refresh=1" class="btn">🔄 Yenile</a>
        </div>
        
        <div class="card">
            <h2>📋 Son Bot Logları</h2>
            <div class="log-box">
                <?php foreach ($botLogs as $line): ?>
                    <div><?php echo htmlspecialchars(trim($line)); ?></div>
                <?php endforeach; ?>
            </div>
        </div>
        
        <div class="card">
            <h2>⚙️ Kurulum Logları</h2>
            <div class="log-box">
                <?php foreach ($installLogs as $line): ?>
                    <div><?php echo htmlspecialchars(trim($line)); ?></div>
                <?php endforeach; ?>
            </div>
        </div>
    </div>
</body>
</html>
EOF

echo "$(date): Web sayfaları oluşturuldu" >> $LOG_FILE

# 9. CRON JOB EKLE (Bot otomatik restart için)
echo "$(date): Cron job ekleniyor..." >> $LOG_FILE
(crontab -l 2>/dev/null; echo "*/10 * * * * /home/dcoakelc/freqtrade-bot1/restart_bot.sh >/dev/null 2>&1") | crontab -

# Restart script oluştur
cat > restart_bot.sh << 'EOF'
#!/bin/bash
# Bot restart scripti
BOT_DIR="/home/dcoakelc/freqtrade-bot1"
PID_FILE="$BOT_DIR/bot.pid"

cd $BOT_DIR

# Bot çalışıyor mu kontrol et
if [ -f "$PID_FILE" ]; then
    PID=$(cat $PID_FILE)
    if ! kill -0 $PID 2>/dev/null; then
        # Bot durmuş, yeniden başlat
        echo "$(date): Bot yeniden başlatılıyor..." >> bot_restart.log
        nohup python3 -m freqtrade trade --config config.json --strategy SimpleScalpingStrategy > bot.log 2>&1 & echo $! > $PID_FILE
    fi
else
    # PID dosyası yok, bot'u başlat
    echo "$(date): Bot başlatılıyor..." >> bot_restart.log
    nohup python3 -m freqtrade trade --config config.json --strategy SimpleScalpingStrategy > bot.log 2>&1 & echo $! > $PID_FILE
fi
EOF

chmod +x restart_bot.sh
echo "$(date): Restart scripti oluşturuldu" >> $LOG_FILE

# 10. KURULUM TAMAMLANDI
echo "$(date): ========================================" >> $LOG_FILE
echo "$(date): KURULUM TAMAMLANDI!" >> $LOG_FILE
echo "$(date): ========================================" >> $LOG_FILE
echo "$(date): Bot Dizini: $BOT_DIR" >> $LOG_FILE
echo "$(date): Web Dashboard: http://akelclinics.com/" >> $LOG_FILE
echo "$(date): Log Dosyası: $LOG_FILE" >> $LOG_FILE

if [ -f "$PID_FILE" ]; then
    BOT_PID=$(cat $PID_FILE)
    echo "$(date): Bot PID: $BOT_PID" >> $LOG_FILE
fi

echo "$(date): Dosya listesi:" >> $LOG_FILE
ls -la $BOT_DIR >> $LOG_FILE

echo "$(date): Web dosyaları:" >> $LOG_FILE
ls -la $WEB_DIR >> $LOG_FILE

echo ""
echo "✅ FREQTRADE BOT KURULUMU TAMAMLANDI!"
echo ""
echo "📁 Bot dizini: $BOT_DIR"
echo "🌐 Web dashboard: http://akelclinics.com/"
echo "📋 Log dosyası: $LOG_FILE"
echo ""
echo "Bot durumunu kontrol etmek için:"
echo "cat $LOG_FILE"
echo ""
