# Freqtrade Bot - cPanel File Manager Kurulum Rehberi

## 🚀 SSH Terminal Olmadan Kurulum

cPanel'de SSH terminal bulunamadığı için File Manager üzerinden kurulum yapacağız.

### Yöntem 1: File Manager + cPanel API (Önerilen)

1. **cPanel'e giriş yapın:**
   - Panel: http://93.89.225.129:2082
   - Kullanıcı: dcoakelc
   - Şifre: 8[vH8}lL

2. **File Manager'ı açın:**
   - cPanel ana sayfasında "File Manager" bulun
   - Home directory (/home/dcoakelc/) açın

3. **Terminal alternatifi:**
   - cPanel'de "Cron Jobs" bölümünü bulun
   - VEYA "Terminal" alternatifi olarak:

### Yöntem 2: GitHub Raw Files ile Manuel İndirme

File Manager üzerinden her dosyayı tek tek oluşturacağız:

#### Adım 1: Dizin oluşturun
File Manager'da: `freqtrade-bot` klasörü oluşturun

#### Adım 2: Dosyaları tek tek oluşturun

**config.json:**
```
File Manager -> New File -> config.json
İçeriğini GitHub'dan kopyalayın: 
https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/config.json
```

**UltraAggressiveScalpingStrategy.py:**
```
File Manager -> New File -> UltraAggressiveScalpingStrategy.py
İçeriğini GitHub'dan kopyalayın:
https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/UltraAggressiveScalpingStrategy.py
```

**requirements.txt:**
```
File Manager -> New File -> requirements.txt
İçeriğini GitHub'dan kopyalayın:
https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/requirements.txt
```

**start_bot.sh:**
```
File Manager -> New File -> start_bot.sh
İçeriğini GitHub'dan kopyalayın:
https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/start_bot.sh
Dosyaya sağ tıklayın -> Change Permissions -> 755
```

#### Adım 3: Python paketlerini yükleyin

cPanel'de "Python Selector" veya "Python Apps" bölümünü bulun:
- Python 3.8+ seçin
- pip install freqtrade ccxt pandas numpy

#### Adım 4: Cron Job ile başlatın

cPanel'de "Cron Jobs" bölümü:
- Command: `/home/dcoakelc/freqtrade-bot/start_bot.sh`
- Schedule: Her dakika (veya istediğiniz sıklık)

### Yöntem 3: Web-based Terminal

Bazı hosting sağlayıcıları web-based terminal sunar:
- cPanel'de "Terminal" veya "SSH Access" arayın
- "Web Terminal" veya "Browser Terminal" olabilir

### Kolay Kurulum Scripti

Eğer herhangi bir şekilde komut çalıştırabilirseniz:

```bash
cd /home/dcoakelc/
mkdir -p freqtrade-bot && cd freqtrade-bot
wget https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/config.json
wget https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/UltraAggressiveScalpingStrategy.py
wget https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/requirements.txt
wget https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/start_bot.sh
chmod +x start_bot.sh
pip3 install --user freqtrade ccxt pandas numpy
```

### API Anahtarları Güncelleme

config.json dosyasında şu satırları bulun ve güncelleyin:
```json
"key": "YOUR_BINANCE_TESTNET_API_KEY",
"secret": "YOUR_BINANCE_TESTNET_SECRET_KEY"
```

### Bot'u Başlatma

1. **Cron Job ile (Önerilen):**
   - cPanel -> Cron Jobs
   - Command: `/home/dcoakelc/freqtrade-bot/start_bot.sh`

2. **Manuel başlatma (eğer terminal varsa):**
   ```bash
   cd /home/dcoakelc/freqtrade-bot
   ./start_bot.sh
   ```

### Monitoring

- Log dosyası: `/home/dcoakelc/freqtrade-bot/freqtrade.log`
- File Manager'dan log dosyasını açarak bot durumunu izleyebilirsiniz

### Web UI (Opsiyonel)

Eğer portlar açıksa:
- http://akelclinics.com:8080
- cPanel -> "SubDomains" ile subdomain oluşturabilirsiniz

### Sorun Giderme

1. **Python yoksa:**
   - cPanel -> Python Selector
   - Python 3.8+ seçin

2. **İzin sorunu:**
   - File Manager'da .sh dosyalarına 755 izni verin

3. **Port sorunu:**
   - cPanel -> "IP Blocker" veya "Firewall" ayarları

### GitHub Repository

Tüm dosyalar burada: https://github.com/mhmt23/freqtrade-bot

Raw dosya linkleri:
- config.json: https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/config.json
- strategy: https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/UltraAggressiveScalpingStrategy.py
- requirements: https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/requirements.txt
- start script: https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/start_bot.sh
