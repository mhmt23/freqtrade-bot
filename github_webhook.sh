#!/bin/bash
# GitHub Webhook handler - otomatik deployment için
# Bu dosyayı web server olarak çalıştırabilirsiniz

# GitHub'dan webhook geldiğinde çalışacak script
handle_webhook() {
    echo "📡 GitHub webhook alındı: $(date)"
    
    # Auto deploy scriptini çalıştır
    cd /home/dcoakelc/
    if [ -f auto_deploy.sh ]; then
        ./auto_deploy.sh
        echo "✅ Deployment tamamlandı"
    else
        echo "❌ auto_deploy.sh bulunamadı"
    fi
}

# Basit HTTP server (Python ile)
start_webhook_server() {
    echo "🌐 Webhook server başlatılıyor..."
    
    # Python webhook server
    cat > webhook_server.py << 'EOF'
#!/usr/bin/env python3
import http.server
import socketserver
import json
import subprocess
import os

class WebhookHandler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/webhook':
            # GitHub webhook'u işle
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                # JSON parse et
                data = json.loads(post_data.decode('utf-8'))
                
                # Sadece push eventleri için deployment yap
                if data.get('ref') == 'refs/heads/master':
                    print("🚀 Master branch güncellendi, deployment başlatılıyor...")
                    
                    # Auto deploy scriptini çalıştır
                    result = subprocess.run(['./auto_deploy.sh'], 
                                          capture_output=True, text=True)
                    
                    if result.returncode == 0:
                        response = "✅ Deployment başarılı"
                    else:
                        response = f"❌ Deployment hatası: {result.stderr}"
                else:
                    response = "ℹ️ Master branch değil, deployment yapılmadı"
                    
            except Exception as e:
                response = f"❌ Webhook işleme hatası: {str(e)}"
            
            # Response gönder
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(response.encode('utf-8'))
            print(response)
        else:
            self.send_response(404)
            self.end_headers()

PORT = 8888
with socketserver.TCPServer(("", PORT), WebhookHandler) as httpd:
    print(f"🌐 Webhook server çalışıyor: http://localhost:{PORT}/webhook")
    httpd.serve_forever()
EOF

    chmod +x webhook_server.py
    nohup python3 webhook_server.py > webhook.log 2>&1 &
    echo $! > webhook.pid
    echo "✅ Webhook server başlatıldı (PID: $(cat webhook.pid))"
    echo "📡 Webhook URL: http://akelclinics.com:8888/webhook"
}

# Ana fonksiyon
case "$1" in
    "server")
        start_webhook_server
        ;;
    "deploy")
        handle_webhook
        ;;
    *)
        echo "Kullanım:"
        echo "  $0 server  - Webhook server başlat"
        echo "  $0 deploy  - Manuel deployment"
        ;;
esac
