#!/usr/bin/env python3
"""
Freqtrade Bot - Sunucu Upload Scripti
Bu script dosyaları FTP ile sunucuya yükler.
"""

import ftplib
import os
import sys

# FTP bilgileri
FTP_HOST = "ftp.akelclinics.com"
FTP_USER = "dcoakelc"
FTP_PASS = "8[vH8}lL"
FTP_DIR = "/public_html/freqtrade_bot/"  # Hedef klasör

def upload_files():
    """Dosyaları FTP ile yükle"""
    
    # Yüklenecek dosyalar
    files_to_upload = [
        "config.json",
        "requirements.txt", 
        "UltraAggressiveScalpingStrategy.py",
        "start_bot.sh",
        "stop_bot.sh",
        "README.md"
    ]
    
    try:
        # FTP bağlantısı
        print(f"FTP sunucusuna bağlanıyor: {FTP_HOST}")
        ftp = ftplib.FTP(FTP_HOST)
        ftp.login(FTP_USER, FTP_PASS)
        
        print("Bağlantı başarılı!")
        print("Mevcut dizin:", ftp.pwd())
        
        # Hedef klasörü oluştur
        try:
            ftp.mkd(FTP_DIR.strip('/'))
            print(f"Klasör oluşturuldu: {FTP_DIR}")
        except ftplib.error_perm:
            print(f"Klasör zaten mevcut: {FTP_DIR}")
        
        # Hedef klasöre geç
        ftp.cwd(FTP_DIR.strip('/'))
        print(f"Dizin değiştirildi: {ftp.pwd()}")
        
        # Dosyaları yükle
        for filename in files_to_upload:
            if os.path.exists(filename):
                print(f"Yükleniyor: {filename}")
                with open(filename, 'rb') as file:
                    ftp.storbinary(f'STOR {filename}', file)
                print(f"✓ Yüklendi: {filename}")
            else:
                print(f"✗ Dosya bulunamadı: {filename}")
        
        # Bash scriptlerini executable yap (chmod +x)
        for script in ["start_bot.sh", "stop_bot.sh"]:
            try:
                ftp.sendcmd(f'SITE CHMOD 755 {script}')
                print(f"✓ {script} çalıştırılabilir yapıldı")
            except:
                print(f"? {script} için chmod başarısız (normal olabilir)")
        
        print("\n" + "="*50)
        print("YÜKLEME TAMAMLANDI!")
        print("="*50)
        print(f"Dosyalar yüklendi: {FTP_HOST}{FTP_DIR}")
        print("\nSONRAKİ ADIMLAR:")
        print("1. cPanel File Manager'a girin")
        print("2. freqtrade_bot klasörüne gidin") 
        print("3. config.json dosyasını düzenleyin - API anahtarlarınızı ekleyin")
        print("4. Terminal'e girin:")
        print("   cd freqtrade_bot")
        print("   chmod +x *.sh")
        print("   ./start_bot.sh")
        print("\nWeb UI: http://akelclinics.com:8080")
        
        ftp.quit()
        
    except Exception as e:
        print(f"Hata: {e}")
        sys.exit(1)

if __name__ == "__main__":
    print("Freqtrade Bot - Sunucu Upload")
    print("="*40)
    
    # Mevcut dizini kontrol et
    current_dir = os.getcwd()
    print(f"Mevcut dizin: {current_dir}")
    
    if not os.path.exists("config.json"):
        print("HATA: config.json bulunamadı!")
        print("Bu scripti server_deploy klasöründe çalıştırın.")
        sys.exit(1)
    
    # Upload başlat
    upload_files()
