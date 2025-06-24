# GitHub'dan Otomatik Deployment Kurulumu

## 🔄 GitHub Push → Sunucu Otomatik Güncelleme

Artık GitHub'a push yaptığınızda sunucu otomatik olarak güncellenebilir!

### **Yöntem 1: Cron Jobs ile Periyodik Güncelleme (EN KOLAY)**

#### Adım 1: cPanel → Cron Jobs
```
Command: cd /home/dcoakelc && wget -O auto_deploy.sh https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/auto_deploy.sh && chmod +x auto_deploy.sh && ./auto_deploy.sh
Schedule: Her 5 dakikada bir
```

Bu sayede her 5 dakikada GitHub'dan kontrol eder ve güncelleme varsa çeker.

#### Adım 2: Cron Job Ayarları
- **Minute:** */5
- **Hour:** *
- **Day:** *
- **Month:** *
- **Weekday:** *

### **Yöntem 2: GitHub Webhook ile Anında Güncelleme**

#### Adım 1: Sunucuda webhook server kurun
```bash
cd /home/dcoakelc
wget https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/github_webhook.sh
chmod +x github_webhook.sh
./github_webhook.sh server
```

#### Adım 2: GitHub Repository'de Webhook ekleyin
1. **GitHub → Repository → Settings → Webhooks**
2. **Add webhook:**
   - **Payload URL:** http://akelclinics.com:8888/webhook
   - **Content type:** application/json
   - **Events:** Just the push event
3. **Add webhook**

### **Yöntem 3: Basit Git Pull ile Manuel Güncelleme**

#### Tek komutla güncelleme scripti:
```bash
#!/bin/bash
cd /home/dcoakelc/freqtrade-bot
git pull origin master
chmod +x *.sh
./stop_bot.sh
./start_bot.sh
```

### **Kullanım Senaryoları:**

#### **Senaryo 1: Kod değişikliği yaptınız**
1. ✅ Yerel değişiklikleri yapın
2. ✅ `git push origin master`
3. ✅ Sunucu otomatik güncellenir (5 dakika içinde)
4. ✅ Bot yeniden başlar

#### **Senaryo 2: Hızlı güncelleme istiyorsunuz**
1. ✅ GitHub'a push yapın
2. ✅ cPanel → Cron Jobs → Manual olarak çalıştırın
3. ✅ Anında güncellenir

#### **Senaryo 3: Strategy değişikliği**
1. ✅ UltraAggressiveScalpingStrategy.py'yi düzenleyin
2. ✅ Git push
3. ✅ Sunucu yeni strategy ile çalışır

### **Avantajlar:**

✅ **Kolay yönetim:** Sadece GitHub'a push yapın
✅ **Otomatik güncelleme:** Manuel müdahale gerektirmez  
✅ **Versiyon kontrolü:** Git history ile geri alma
✅ **Güvenli:** Sadece master branch'den çeker
✅ **Log takibi:** Tüm değişiklikler loglanır

### **Kurulum için Hızlı Komutlar:**

```bash
# 1. Auto deploy scriptini indir ve çalıştır
cd /home/dcoakelc
wget https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/auto_deploy.sh
chmod +x auto_deploy.sh
./auto_deploy.sh

# 2. Webhook server başlat (opsiyonel)
wget https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/github_webhook.sh
chmod +x github_webhook.sh
./github_webhook.sh server
```

### **cPanel Cron Job Ayarı:**

**Command:**
```bash
cd /home/dcoakelc && if [ -f auto_deploy.sh ]; then ./auto_deploy.sh; else wget -O auto_deploy.sh https://raw.githubusercontent.com/mhmt23/freqtrade-bot/master/auto_deploy.sh && chmod +x auto_deploy.sh && ./auto_deploy.sh; fi
```

**Schedule:** */5 * * * * (Her 5 dakika)

### **Test:**

1. **Bir dosyayı değiştirin** (örneğin README.md)
2. **Git push yapın**
3. **5 dakika bekleyin**
4. **Sunucuda değişiklik geldi mi kontrol edin**

Artık GitHub → Sunucu otomatik sync'i hazır! 🚀
