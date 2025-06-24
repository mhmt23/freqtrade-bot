# Freqtrade Bot - cPanel Cron Jobs Kurulum Rehberi

## 🕒 OTOMATIK GITHUB GÜNCELLEME CRON JOB'LARI

### **1. İlk Kurulum (Tek Seferlik)**

**cPanel → Cron Jobs → Add New Cron Job:**

**Command:**
```bash
cd /home/dcoakelc/public_html && wget -O deploy.sh https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/web_deploy.sh && chmod +x deploy.sh && ./deploy.sh
```

**Schedule:** 
- Minute: 0
- Hour: *
- Day: *  
- Month: *
- Weekday: *

**Bu job'ı kaydettikten sonra 5 dakika bekleyin, sonra silin.**

---

### **2. Otomatik Güncelleme (Sürekli)**

**İlk kurulum bittikten sonra bu job'ı ekleyin:**

**Command:**
```bash
cd /home/dcoakelc/public_html/freqtrade-bot && git fetch origin && git reset --hard origin/master && ./web_start_bot.sh
```

**Schedule:** Her 10 dakikada bir
- Minute: */10
- Hour: *
- Day: *
- Month: *
- Weekday: *

---

### **3. Bot Sağlık Kontrolü (Opsiyonel)**

**Bot'un çalışıp çalışmadığını kontrol eden job:**

**Command:**
```bash
cd /home/dcoakelc/public_html/freqtrade-bot && if [ ! -f bot.pid ] || ! ps -p $(cat bot.pid) > /dev/null 2>&1; then ./web_start_bot.sh; fi
```

**Schedule:** Her 5 dakikada bir
- Minute: */5
- Hour: *
- Day: *
- Month: *
- Weekday: *

---

### **4. Durum Sayfası Güncelleme**

**Web durum sayfasını güncelleyen job:**

**Command:**
```bash
cd /home/dcoakelc/public_html/freqtrade-bot && if [ -f freqtrade.log ]; then echo "<h1>Freqtrade Bot Status - $(date)</h1><h2>Bot Durumu:</h2>" > status.html && if [ -f bot.pid ] && ps -p $(cat bot.pid) > /dev/null 2>&1; then echo "<p style='color:green'>✅ Bot ÇALIŞIYOR</p>" >> status.html; else echo "<p style='color:red'>❌ Bot DURDU</p>" >> status.html; fi && echo "<h2>Son 50 Log:</h2><pre>" >> status.html && tail -50 freqtrade.log >> status.html && echo "</pre>" >> status.html; fi
```

**Schedule:** Her 2 dakikada bir
- Minute: */2
- Hour: *
- Day: *
- Month: *
- Weekday: *

---

## 🌐 WEB ERİŞİM NOKTALARI

Kurulum tamamlandıktan sonra:

- **📊 Bot Durumu:** http://akelclinics.com/freqtrade-bot/status.html
- **🌐 Web UI:** http://akelclinics.com:8080
- **📝 Ham Log:** http://akelclinics.com/freqtrade-bot/freqtrade.log

---

## ⚡ TEK KOMUT KURULUM

Eğer cPanel'de terminal bulursanız:

```bash
cd /home/dcoakelc/public_html
wget https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/web_deploy.sh
chmod +x web_deploy.sh
./web_deploy.sh
```

---

## 🔧 MANUEL KONTROL KOMUTLARI

```bash
# Bot durumunu kontrol et
cd /home/dcoakelc/public_html/freqtrade-bot
ps aux | grep freqtrade

# Bot'u manuel başlat
./web_start_bot.sh

# Bot'u manuel durdur  
./web_stop_bot.sh

# Log'ları kontrol et
tail -f freqtrade.log
```

---

## 🚨 SORUN GİDERME

1. **Bot başlamıyorsa:** 
   - API anahtarlarını config.json'da kontrol edin
   - Python paketlerinin yüklü olduğunu kontrol edin

2. **Web UI açılmıyorsa:**
   - Port 8080'in açık olduğunu kontrol edin
   - Firewall ayarlarını kontrol edin

3. **Cron job çalışmıyorsa:**
   - cPanel'de "Cron Job Logs" kontrol edin
   - Email bildirimlerini kontrol edin

4. **GitHub güncellemeleri gelmiyor:**
   - Git repository'nin düzgün klonlandığını kontrol edin
   - İnternet bağlantısını kontrol edin
