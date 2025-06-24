#!/bin/bash
# FREQTRADE BOT - TEMİZ KURULUM
# Repository: https://github.com/mhmt23/freqtrade-bot1.git (PUBLIC)
# Tam otomatik kurulum ve bot başlatma

LOG_FILE="/home/dcoakelc/freqtrade_install.log"
BOT_DIR="/home/dcoakelc/freqtrade-bot1"
WEB_DIR="/home/dcoakelc/public_html/freqtrade-bot"
PID_FILE="$BOT_DIR/bot.pid"

echo "========================================" >> $LOG_FILE
echo "$(date): YENİ FREQTRADE KURULUM BAŞLADI" >> $LOG_FILE
echo "Repository: https://github.com/mhmt23/freqtrade-bot1.git" >> $LOG_FILE
echo "========================================" >> $LOG_FILE

# Ana dizine git
cd /home/dcoakelc/
echo "$(date): Ana dizin: $(pwd)" >> $LOG_FILE

# Tüm eski bot dosyalarını temizle
echo "$(date): TÜM eski dosyalar temizleniyor..." >> $LOG_FILE
rm -rf freqtrade-bot* mail bot* trading-bot* crypto-bot*
rm -f freqtrade_*.log deploy.log install_log.txt test_*.txt
echo "$(date): Temizlik tamamlandı" >> $LOG_FILE

# Yeni repository'yi klonla
echo "$(date): GitHub'dan YENİ repository klonlanıyor..." >> $LOG_FILE
git clone https://github.com/mhmt23/freqtrade-bot1.git "$BOT_DIR" >> $LOG_FILE 2>&1

if [ ! -d "$BOT_DIR" ]; then
    echo "$(date): HATA: Repository klonlanamadı!" >> $LOG_FILE
    echo "$(date): Git komutu çıktısı kontrol ediliyor..." >> $LOG_FILE
    git clone https://github.com/mhmt23/freqtrade-bot1.git "$BOT_DIR" >> $LOG_FILE 2>&1
    exit 1
fi

cd "$BOT_DIR"
echo "$(date): Bot dizinine geçildi: $(pwd)" >> $LOG_FILE

# Klonlanan dosyaları listele
echo "$(date): Klonlanan dosyalar:" >> $LOG_FILE
ls -la >> $LOG_FILE 2>&1

# Python paketlerini yükle
echo "$(date): Python paketleri yükleniyor..." >> $LOG_FILE
python3 -m pip install --user --upgrade pip >> $LOG_FILE 2>&1
python3 -m pip install --user freqtrade[all] >> $LOG_FILE 2>&1
python3 -m pip install --user ccxt pandas numpy requests >> $LOG_FILE 2>&1

# Config dosyası oluştur (eğer yoksa)
if [ ! -f "config.json" ]; then
    echo "$(date): Config dosyası oluşturuluyor..." >> $LOG_FILE
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
            "BNB/USDT"
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
        "entry": "limit",
        "exit": "limit",
        "emergency_exit": "market",
        "force_exit": "market",
        "force_entry": "market",
        "stoploss": "market",
        "stoploss_on_exchange": false
    },
    
    "order_time_in_force": {
        "entry": "GTC",
        "exit": "GTC"
    },
    
    "pairlists": [
        {
            "method": "StaticPairList"
        }
    ],
    
    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",
        "listen_port": 8080,
        "verbosity": "error",
        "enable_openapi": false,
        "jwt_secret_key": "freqtrade_secret_2025",
        "CORS_origins": ["*"],
        "username": "freqtrade",
        "password": "freqtrade123"
    },
    
    "bot_name": "FreqtradeBot",
    "initial_state": "running",
    "force_entry_enable": false,
    "internals": {
        "process_throttle_secs": 5
    }
}
EOF
    echo "$(date): ✅ Config dosyası oluşturuldu" >> $LOG_FILE
else
    echo "$(date): ✅ Config dosyası mevcut" >> $LOG_FILE
fi

# Basit strategy oluştur (eğer yoksa)
if [ ! -f "SimpleScalpingStrategy.py" ]; then
    echo "$(date): Strategy dosyası oluşturuluyor..." >> $LOG_FILE
    cat > SimpleScalpingStrategy.py << 'EOF'
from freqtrade.strategy import IStrategy
from pandas import DataFrame
import talib.abstract as ta

class SimpleScalpingStrategy(IStrategy):
    """
    Basit Scalping Strategy - Test için
    """
    
    INTERFACE_VERSION = 3
    
    # Minimal ROI
    minimal_roi = {
        "60": 0.01,   # 1 dakika sonra %1 kar
        "30": 0.02,   # 30 saniye sonra %2 kar
        "0": 0.03     # Hemen %3 kar
    }
    
    # Stoploss
    stoploss = -0.05  # %5 zarar durumunda çık
    
    # Timeframe
    timeframe = '1m'
    
    # Process only new candles
    process_only_new_candles = False
    
    # Startup candle count
    startup_candle_count: int = 30
    
    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        İndikatörler
        """
        # RSI
        dataframe['rsi'] = ta.RSI(dataframe, timeperiod=14)
        
        # SMA
        dataframe['sma_fast'] = ta.SMA(dataframe, timeperiod=5)
        dataframe['sma_slow'] = ta.SMA(dataframe, timeperiod=20)
        
        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Giriş sinyalleri
        """
        dataframe.loc[
            (
                (dataframe['rsi'] < 30) &  # RSI oversold
                (dataframe['close'] > dataframe['sma_fast']) &  # Fiyat hızlı SMA üstünde
                (dataframe['volume'] > 0)  # Volume var
            ),
            'enter_long'] = 1

        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Çıkış sinyalleri
        """
        dataframe.loc[
            (
                (dataframe['rsi'] > 70) |  # RSI overbought
                (dataframe['close'] < dataframe['sma_slow'])  # Fiyat yavaş SMA altında
            ),
            'exit_long'] = 1

        return dataframe
EOF
    echo "$(date): ✅ Strategy dosyası oluşturuldu" >> $LOG_FILE
else
    echo "$(date): ✅ Strategy dosyası mevcut" >> $LOG_FILE
fi

# Web monitoring klasörünü oluştur
mkdir -p "$WEB_DIR"
echo "$(date): Web klasörü oluşturuldu: $WEB_DIR" >> $LOG_FILE

# Bot'u başlat
echo "$(date): Freqtrade bot başlatılıyor..." >> $LOG_FILE
nohup python3 -m freqtrade trade \
    --config config.json \
    --strategy SimpleScalpingStrategy \
    --logfile freqtrade.log \
    > bot_output.log 2>&1 &

BOT_PID=$!
echo $BOT_PID > "$PID_FILE"
echo "$(date): Bot başlatıldı (PID: $BOT_PID)" >> $LOG_FILE

# Bot durumunu kontrol et
sleep 10
if kill -0 $BOT_PID 2>/dev/null; then
    echo "$(date): ✅ Bot başarıyla çalışıyor!" >> $LOG_FILE
    BOT_STATUS="running"
    BOT_STATUS_MSG="✅ Bot Çalışıyor (PID: $BOT_PID)"
else
    echo "$(date): ❌ Bot başlatılamadı, loglar kontrol ediliyor..." >> $LOG_FILE
    echo "$(date): Bot output:" >> $LOG_FILE
    cat bot_output.log >> $LOG_FILE 2>&1
    BOT_STATUS="failed"
    BOT_STATUS_MSG="❌ Bot Başlatılamadı (Logları kontrol edin)"
fi

# Web dashboard oluştur
cat > "$WEB_DIR/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Freqtrade Bot Dashboard</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: Arial, sans-serif; margin: 0; background: #1a1a1a; color: #fff; }
        .container { max-width: 1000px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(45deg, #667eea, #764ba2); padding: 30px; border-radius: 15px; text-align: center; margin-bottom: 30px; }
        .status { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .card { background: #2d2d2d; padding: 20px; border-radius: 10px; border-left: 5px solid #667eea; }
        .running { border-left-color: #28a745; }
        .failed { border-left-color: #dc3545; }
        .refresh { position: fixed; top: 20px; right: 20px; background: #28a745; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; }
        .logs { background: #000; color: #0f0; padding: 15px; border-radius: 10px; font-family: monospace; max-height: 400px; overflow-y: auto; white-space: pre-wrap; }
    </style>
    <script>
        setInterval(() => location.reload(), 30000);
        function manualRefresh() { location.reload(); }
    </script>
</head>
<body>
    <button class="refresh" onclick="manualRefresh()">🔄 Yenile</button>
    
    <div class="container">
        <div class="header">
            <h1>🤖 Freqtrade Trading Bot</h1>
            <p>Otomatik Kripto Para Trading Sistemi</p>
            <small>Son Güncelleme: $(date)</small>
        </div>
        
        <div class="status">
            <div class="card $BOT_STATUS">
                <h3>🚀 Bot Durumu</h3>
                <p>$BOT_STATUS_MSG</p>
                <p>Başlatma: $(date)</p>
            </div>
            
            <div class="card">
                <h3>📈 Trading Bilgileri</h3>
                <p><strong>Exchange:</strong> Binance Testnet</p>
                <p><strong>Strategy:</strong> SimpleScalping</p>
                <p><strong>Pairs:</strong> BTC/USDT, ETH/USDT, BNB/USDT</p>
            </div>
            
            <div class="card">
                <h3>🔧 Sistem</h3>
                <p><strong>Repository:</strong> freqtrade-bot1</p>
                <p><strong>Web UI:</strong> <a href="http://akelclinics.com:8080" target="_blank">Aç</a></p>
                <p><strong>Log:</strong> /home/dcoakelc/freqtrade_install.log</p>
            </div>
        </div>
        
        <h2>📋 Son Bot Logları</h2>
        <div class="logs">
LOGCONTENT
        </div>
    </div>
</body>
</html>
EOF

# Bot loglarını ekle
if [ -f "freqtrade.log" ]; then
    LOG_CONTENT=$(tail -30 freqtrade.log 2>/dev/null || echo "Log dosyası henüz oluşturulmadı...")
else
    LOG_CONTENT="Bot henüz log oluşturmadı..."
fi

sed -i "s/LOGCONTENT/$LOG_CONTENT/" "$WEB_DIR/index.html"

echo "$(date): ✅ Web dashboard oluşturuldu" >> $LOG_FILE

# Özet rapor
echo "========================================" >> $LOG_FILE
echo "$(date): KURULUM TAMAMLANDI!" >> $LOG_FILE
echo "📊 Bot Durumu: $BOT_STATUS_MSG" >> $LOG_FILE
echo "🌐 Dashboard: http://akelclinics.com/freqtrade-bot/" >> $LOG_FILE
echo "💻 Web UI: http://akelclinics.com:8080" >> $LOG_FILE
echo "📂 Bot Klasörü: $BOT_DIR" >> $LOG_FILE
echo "📄 Log Dosyası: $LOG_FILE" >> $LOG_FILE
echo "========================================" >> $LOG_FILE

# Repository bilgilerini güncelle
echo "$(date): Repository: https://github.com/mhmt23/freqtrade-bot1.git" >> $LOG_FILE
echo "$(date): Status: Public repository kullanıldı" >> $LOG_FILE
