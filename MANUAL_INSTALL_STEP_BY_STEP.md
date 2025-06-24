# cPanel Manuel Kurulum - Adım Adım

## 🚨 cPanel'de dosyalar boş görünüyorsa:

### **Yöntem 1: cPanel File Manager ile Manuel Oluşturma**

1. **cPanel'e giriş yapın:**
   - http://93.89.225.129:2082
   - Kullanıcı: dcoakelc  
   - Şifre: 8[vH8}lL

2. **File Manager'ı açın**

3. **freqtrade-bot klasörü oluşturun:**
   - New Folder → "freqtrade-bot"

4. **Dosyaları tek tek oluşturun:**

### **DOSYA 1: config.json**
```
File Manager → freqtrade-bot klasörüne girin → New File → "config.json"
```

Şu içeriği kopyalayın:
```json
{
    "$schema": "https://schema.freqtrade.io/schema.json",
    "max_open_trades": 20,
    "stake_currency": "USDT",
    "stake_amount": 50,
    "tradable_balance_ratio": 1.0,
    "fiat_display_currency": "USD",
    "dry_run": false,
    "cancel_open_orders_on_exit": false,
    "trading_mode": "futures",
    "margin_mode": "isolated",
    "leverage": 5,
    "exchange": {
        "name": "binance",
        "key": "e8affc8584f47d86326c1a6faa9ec55bda712c4236ab72348f15b6f02aeba07d",
        "secret": "bbda4ea2b62645901b1578b820afc721cfe7b9fd82c72a96bb1690d37b3b0fe0",
        "ccxt_config": {
            "sandbox": true,
            "urls": {
                "api": {
                    "public": "https://testnet.binancefuture.com",
                    "private": "https://testnet.binancefuture.com"
                }
            }
        },
        "pair_whitelist": [
            "BTC/USDT:USDT", "ETH/USDT:USDT", "ADA/USDT:USDT", "SOL/USDT:USDT",
            "XRP/USDT:USDT", "DOT/USDT:USDT", "DOGE/USDT:USDT", "AVAX/USDT:USDT",
            "LTC/USDT:USDT", "LINK/USDT:USDT", "UNI/USDT:USDT", "ATOM/USDT:USDT",
            "ETC/USDT:USDT", "XLM/USDT:USDT", "BCH/USDT:USDT", "ALGO/USDT:USDT"
        ]
    },
    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",
        "listen_port": 8080,
        "username": "admin",
        "password": "123456"
    },
    "db_url": "sqlite:///tradesv3.sqlite"
}
```

### **DOSYA 2: requirements.txt**
```
File Manager → New File → "requirements.txt"
```

İçerik:
```
freqtrade
ccxt>=4.0.0
pandas
numpy
requests
```

### **DOSYA 3: start_bot.sh**
```
File Manager → New File → "start_bot.sh"
```

İçerik:
```bash
#!/bin/bash
cd /home/dcoakelc/freqtrade-bot
pip3 install --user freqtrade ccxt pandas numpy
nohup python3 -m freqtrade trade --config config.json > freqtrade.log 2>&1 &
echo $! > bot.pid
echo "Bot baslatildi"
```

Dosyaya sağ tıklayın → Change Permissions → **755**

### **DOSYA 4: stop_bot.sh**
```
File Manager → New File → "stop_bot.sh"
```

İçerik:
```bash
#!/bin/bash
cd /home/dcoakelc/freqtrade-bot
if [ -f bot.pid ]; then
    kill $(cat bot.pid) 2>/dev/null
    rm -f bot.pid
    echo "Bot durduruldu"
else
    echo "Bot PID bulunamadi"
fi
```

Dosyaya sağ tıklayın → Change Permissions → **755**

### **Yöntem 2: Cron Jobs ile Kurulum**

1. **cPanel → Cron Jobs**
2. **Add New Cron Job:**
   - Command: `cd /home/dcoakelc && wget https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/simple_install.sh && chmod +x simple_install.sh && ./simple_install.sh`
   - Minute: `*`
   - Hour: `*`
   - Day: `*`
   - Month: `*`
   - Weekday: `*`

3. **Kaydet ve bekleyin** (1-2 dakika)
4. **Cron Job'ı silin** (tek seferlik)

### **Yöntem 3: Python Apps (Eğer destekleniyorsa)**

1. **cPanel → Python Apps**
2. **Create Application**
3. **Python Version:** 3.8+
4. **App Directory:** freqtrade-bot
5. **Requirements dosyasını yükleyin**

### **Bot'u Başlatma:**

1. **Terminal bulursanız:**
```bash
cd /home/dcoakelc/freqtrade-bot
./start_bot.sh
```

2. **Cron Jobs ile:**
   - Command: `/home/dcoakelc/freqtrade-bot/start_bot.sh`
   - Schedule: Her 5 dakikada bir (bot zaten çalışıyorsa duplicate olmaz)

### **Kontrol:**

- **Log dosyası:** `/home/dcoakelc/freqtrade-bot/freqtrade.log`
- **File Manager'dan log dosyasını açın**

### **Web UI:**

- **URL:** http://akelclinics.com:8080
- **Username:** admin
- **Password:** 123456

### **Sorun Giderme:**

- cPanel cache → Hard refresh (Ctrl+F5)
- File Manager → Show Hidden Files aktif edin
- File permissions → 644 (dosyalar), 755 (scriptler)

## 📞 Son Çare:

Eğer hiçbir yöntem çalışmazsa, hosting desteğinizle iletişime geçin ve "Python web application" kurabilir miyim diye sorun.
