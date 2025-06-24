# Freqtrade Bot - Sunucu Deployment

🤖 **OTOMATIK DEPLOYMENT AKTİF!** 🤖

Bu klasör Freqtrade botunu Linux sunucunda çalıştırmak için gerekli dosyaları içerir.
GitHub'a push yaptığınızda sunucu otomatik güncellenir!

## Kurulum Adımları

### 1. Dosyaları Sunucuya Yükleyin
- Tüm dosyaları cPanel File Manager ile sunucunuza yükleyin
- Önerilen konum: `/home/dcoakelc/freqtrade_bot/`

### 2. API Anahtarlarını Güncelleyin
`config.json` dosyasını düzenleyin:
```json
"key": "BINANCE_API_KEY_BURAYA",
"secret": "BINANCE_SECRET_KEY_BURAYA"
```

### 3. Scriptleri Çalıştırılabilir Yapın
```bash
chmod +x start_bot.sh
chmod +x stop_bot.sh
```

### 4. Botu Başlatın
```bash
./start_bot.sh
```

## Kullanım

### Bot Başlatma
```bash
./start_bot.sh
```

### Bot Durdurma
```bash
./stop_bot.sh
```

### Logları İzleme
```bash
tail -f freqtrade.log
```

### Bot Durumunu Kontrol
```bash
ps aux | grep freqtrade
```

## Web Arayüzü

Bot başladıktan sonra web arayüzüne erişebilirsiniz:
- URL: `http://SUNUCU_IP:8080`
- Kullanıcı: admin
- Şifre: config.json'da belirtilen şifre

## Önemli Notlar

### Güvenlik
- **SADECE TESTNET** kullanın! `sandbox: true` ayarı aktif.
- API anahtarlarınızı güvenli tutun.
- Web UI şifresini değiştirin.

### Port Yönetimi
- Bot 8080 portunu kullanır.
- cPanel'de port açmanız gerekebilir.

### Performans
- Bot 1 dakikalık timeframe kullanır.
- 20 farklı coin çiftinde işlem yapar.
- Maksimum 20 açık pozisyon.

### Sorun Giderme
- Log dosyası: `freqtrade.log`
- Hata durumunda: `./stop_bot.sh && ./start_bot.sh`

## Dosya Yapısı

```
├── config.json              # Bot konfigürasyonu
├── requirements.txt         # Python bağımlılıkları  
├── UltraAggressiveScalpingStrategy.py  # Trading stratejisi
├── start_bot.sh            # Başlatma scripti
├── stop_bot.sh             # Durdurma scripti
├── README.md               # Bu dosya
├── venv/                   # Virtual environment (otomatik oluşur)
├── freqtrade.log          # Log dosyası (otomatik oluşur)
├── freqtrade.pid          # Process ID (otomatik oluşur)
└── tradesv3.live.sqlite   # Veritabanı (otomatik oluşur)
```

## Destek

Sorun yaşarsanız:
1. `freqtrade.log` dosyasını kontrol edin
2. Bot durumunu kontrol edin: `ps aux | grep freqtrade`
3. Gerekirse botu yeniden başlatın

**UYARI: Bu sadece test amaçlıdır. Gerçek para ile test etmeyin!**
