# FREQTRADE BOT - MANUEL KURULUM REHBERİ
# GitHub'sız Kurulum - Dosya Upload Yöntemi

## 📁 Gerekli Dosyalar

Serverde şu klasör yapısını oluşturun:
```
/home/dcoakelc/
├── bot_files/              # Bu klasöre dosyaları yükleyin
│   ├── config.json
│   ├── SimpleScalpingStrategy.py
│   ├── requirements_simple.txt
│   └── local_install.sh
└── public_html/            # Web dashboard buraya kurulacak
```

## 🚀 Kurulum Adımları

### 1. Dosya Yükleme Klasörü Oluştur
```bash
mkdir -p /home/dcoakelc/bot_files
cd /home/dcoakelc/bot_files
```

### 2. Gerekli Dosyaları Upload Edin

#### A) config.json
```json
{
    "max_open_trades": 5,
    "stake_currency": "USDT",
    "stake_amount": "unlimited",
    "tradable_balance_ratio": 0.1,
    "fiat_display_currency": "USD",
    "dry_run": true,
    "dry_run_wallet": 10000,
    "cancel_open_orders_on_exit": false,
    "trading_mode": "spot",
    "margin_mode": "",
    "unfilledtimeout": {
        "entry": 10,
        "exit": 10,
        "exit_timeout_count": 0,
        "unit": "minutes"
    },
    "entry_pricing": {
        "price_side": "same",
        "use_order_book": true,
        "order_book_top": 1,
        "price_last_balance": 0.0,
        "check_depth_of_market": {
            "enabled": false,
            "bids_to_ask_delta": 1
        }
    },
    "exit_pricing": {
        "price_side": "same",
        "use_order_book": true,
        "order_book_top": 1
    },
    "exchange": {
        "name": "binance",
        "sandbox": true,
        "key": "vmPUZE6mv9SD5VNHk4HlWFsOr6aKE2zvsw0MuIgwCIPy6utIco14y7Ju91duEh8A",
        "secret": "NhqPtmdSJYdKjVHjA7PZj4Mge3R5YNiP1e3UZjInClVN65XAbvqqM6A7H5fATj0j",
        "ccxt_config": {},
        "ccxt_async_config": {},
        "pair_whitelist": [
            "BTC/USDT",
            "ETH/USDT",
            "BNB/USDT",
            "ADA/USDT",
            "DOT/USDT"
        ],
        "pair_blacklist": []
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
        "enabled": true,
        "listen_ip_address": "0.0.0.0",
        "listen_port": 8080,
        "verbosity": "error",
        "enable_openapi": false,
        "jwt_secret_key": "supersecret",
        "CORS_origins": [],
        "username": "admin",
        "password": "admin123"
    },
    "bot_name": "FreqtradeBot",
    "initial_state": "running",
    "force_entry_enable": false,
    "internals": {
        "process_throttle_secs": 5
    }
}
```

#### B) SimpleScalpingStrategy.py
```python
import numpy as np
import pandas as pd
from freqtrade.strategy import IStrategy, DecimalParameter, IntParameter
import talib.abstract as ta

class SimpleScalpingStrategy(IStrategy):
    """
    Basit Scalping Stratejisi - Binance Testnet için optimize edilmiş
    Kısa vadeli fiyat hareketlerinden yararlanır
    """
    
    INTERFACE_VERSION = 3
    minimal_roi = {
        "0": 0.02,  # 2% kar hedefi
        "5": 0.015, # 5 dakika sonra 1.5%
        "15": 0.01, # 15 dakika sonra 1%
        "30": 0.005 # 30 dakika sonra 0.5%
    }
    
    stoploss = -0.03  # 3% stop loss
    
    # Optimal timeframe
    timeframe = '5m'
    
    # ROI ve stoploss için dinamik ayar
    use_exit_signal = True
    exit_profit_only = False
    ignore_roi_if_entry_signal = False
    
    # Parametre optimizasyonu için
    rsi_period = IntParameter(10, 20, default=14, space="buy")
    rsi_buy = IntParameter(20, 40, default=30, space="buy")
    rsi_sell = IntParameter(60, 80, default=70, space="sell")
    
    ema_short = IntParameter(8, 15, default=12, space="buy")
    ema_long = IntParameter(20, 30, default=26, space="buy")
    
    volume_check = DecimalParameter(1.0, 3.0, default=1.5, space="buy")

    def populate_indicators(self, dataframe: pd.DataFrame, metadata: dict) -> pd.DataFrame:
        """Teknik indikatörleri hesapla"""
        
        # RSI
        dataframe['rsi'] = ta.RSI(dataframe, timeperiod=self.rsi_period.value)
        
        # EMA'lar
        dataframe['ema_short'] = ta.EMA(dataframe, timeperiod=self.ema_short.value)
        dataframe['ema_long'] = ta.EMA(dataframe, timeperiod=self.ema_long.value)
        
        # MACD
        macd = ta.MACD(dataframe)
        dataframe['macd'] = macd['macd']
        dataframe['macdsignal'] = macd['macdsignal']
        dataframe['macdhist'] = macd['macdhist']
        
        # Bollinger Bands
        bollinger = ta.BBANDS(dataframe)
        dataframe['bb_lower'] = bollinger['lowerband']
        dataframe['bb_middle'] = bollinger['middleband']
        dataframe['bb_upper'] = bollinger['upperband']
        
        # Volume SMA (ortalama volume)
        dataframe['volume_sma'] = ta.SMA(dataframe['volume'], timeperiod=20)
        
        # ATR (Average True Range) - volatilite ölçümü
        dataframe['atr'] = ta.ATR(dataframe, timeperiod=14)
        
        # Stochastic
        stoch = ta.STOCH(dataframe)
        dataframe['stoch_k'] = stoch['slowk']
        dataframe['stoch_d'] = stoch['slowd']
        
        return dataframe

    def populate_entry_trend(self, dataframe: pd.DataFrame, metadata: dict) -> pd.DataFrame:
        """Giriş sinyallerini tanımla"""
        
        conditions = []
        
        # RSI düşük (oversold)
        conditions.append(dataframe['rsi'] < self.rsi_buy.value)
        
        # EMA kısa > EMA uzun (yükseliş trendi)
        conditions.append(dataframe['ema_short'] > dataframe['ema_long'])
        
        # MACD pozitif momentum
        conditions.append(dataframe['macd'] > dataframe['macdsignal'])
        
        # Fiyat Bollinger alt bandına yakın
        conditions.append(dataframe['close'] <= dataframe['bb_lower'] * 1.02)
        
        # Volume normalden yüksek
        conditions.append(dataframe['volume'] > dataframe['volume_sma'] * self.volume_check.value)
        
        # Stochastic oversold
        conditions.append(dataframe['stoch_k'] < 20)
        
        # Tüm koşullar sağlandığında giriş yap
        if conditions:
            dataframe.loc[
                reduce(lambda x, y: x & y, conditions),
                'enter_long'
            ] = 1
        
        return dataframe

    def populate_exit_trend(self, dataframe: pd.DataFrame, metadata: dict) -> pd.DataFrame:
        """Çıkış sinyallerini tanımla"""
        
        conditions = []
        
        # RSI yüksek (overbought)
        conditions.append(dataframe['rsi'] > self.rsi_sell.value)
        
        # MACD negatif momentum
        conditions.append(dataframe['macd'] < dataframe['macdsignal'])
        
        # Fiyat Bollinger üst bandına yakın
        conditions.append(dataframe['close'] >= dataframe['bb_upper'] * 0.98)
        
        # Stochastic overbought
        conditions.append(dataframe['stoch_k'] > 80)
        
        # Herhangi bir koşul sağlandığında çıkış yap
        if conditions:
            dataframe.loc[
                reduce(lambda x, y: x | y, conditions),
                'exit_long'
            ] = 1
        
        return dataframe

# Yardımcı fonksiyon
def reduce(function, iterable, initializer=None):
    """Reduce fonksiyonu - koşulları birleştirmek için"""
    it = iter(iterable)
    if initializer is None:
        value = next(it)
    else:
        value = initializer
    for element in it:
        value = function(value, element)
    return value
```

#### C) requirements_simple.txt
```
freqtrade[complete]
ccxt>=4.0.0
pandas>=1.5.0
numpy>=1.21.0
ta-lib>=0.4.0
requests>=2.28.0
```

#### D) local_install.sh
(Yukarıda oluşturduğumuz script dosyası)

### 3. Kurulum Script'ini Çalıştır
```bash
cd /home/dcoakelc/bot_files
chmod +x local_install.sh
./local_install.sh
```

## 📊 Sonuçlar

Kurulum başarılı olursa:
- 🌐 **Web Dashboard:** http://akelclinics.com/
- 📋 **Loglar:** http://akelclinics.com/logs.html
- ⚡ **Canlı Status:** http://akelclinics.com/status.php

## 🔧 Bot Yönetimi

### Bot'u Yeniden Başlat
```bash
/home/dcoakelc/freqtrade-bot1/restart_bot.sh
```

### Log Kontrolü
```bash
tail -f /home/dcoakelc/freqtrade_install.log
tail -f /home/dcoakelc/freqtrade-bot1/freqtrade.log
```

### Bot Durumu Kontrol
```bash
ps aux | grep freqtrade
cat /home/dcoakelc/freqtrade-bot1/bot.pid
```

## 🚨 Sorun Giderme

1. **Python paket hatası:** `pip3 install --user paket_adı`
2. **İzin hatası:** `chmod +x dosya_adı`
3. **API hatası:** config.json'da API anahtarlarını kontrol edin
4. **Strategy hatası:** SimpleScalpingStrategy.py dosyasını kontrol edin

## 📁 Dosya Yapısı (Kurulum Sonrası)
```
/home/dcoakelc/
├── bot_files/              # Upload edilen dosyalar
├── freqtrade-bot1/         # Bot çalışma dizini
│   ├── config.json
│   ├── SimpleScalpingStrategy.py
│   ├── freqtrade.log
│   ├── bot_output.log
│   ├── bot.pid
│   └── restart_bot.sh
├── public_html/            # Web interface
│   ├── index.html
│   ├── logs.html
│   └── status.php
└── freqtrade_install.log   # Kurulum logları
```
