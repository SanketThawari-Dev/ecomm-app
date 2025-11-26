#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🔄 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing dependencies..."
sudo apt install -y python3-pip python3-venv nginx mysql-server vsftpd

echo "🧹 Removing default Nginx index page..."
rm -rf /var/www/html/index.nginx-debian.html

echo "🔧 Setting permissions for /var/www/html..."
sudo chown -R ubuntu:ubuntu /var/www/html
sudo chmod -R 755 /var/www/html

cd /var/www/html

echo "📝 Creating requirements.txt..."
cat <<EOF > requirements.txt
Flask
mysql-connector-python
gunicorn
EOF

echo "🐍 Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
deactivate

echo "🔐 Securing MySQL installation..."
# Automating mysql_secure_installation using heredoc
sudo mysql_secure_installation <<EOF

y
0
y
n
y
y
EOF

echo "🗄️ Importing database..."
# Just press Enter when prompted for password
sudo mysql -u root -p < /var/www/html/db.sql

echo "🌐 Creating Nginx config for techmspire..."
sudo tee /etc/nginx/sites-available/techmspire.conf > /dev/null <<EOF
server {
    listen 80;
    server_name your_domain_or_ip;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /static/ {
        alias /var/www/html/api/;
    }
}
EOF

echo "🧹 Removing default Nginx site configs..."
sudo rm -rf /etc/nginx/sites-available/default
sudo rm -rf /etc/nginx/sites-enabled/default

echo "🔗 Enabling techmspire site..."
sudo ln -s /etc/nginx/sites-available/techmspire.conf /etc/nginx/sites-enabled/

echo "🔄 Restarting Nginx and MySQL..."
sudo systemctl restart nginx
sudo systemctl restart mysql.service

echo "⚙️ Creating Gunicorn systemd service..."
sudo tee /etc/systemd/system/gunicorn.service > /dev/null <<EOF
[Unit]
Description=Gunicorn for Techmspire Flask app
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/var/www/html
Environment="PATH=/var/www/html/venv/bin"
ExecStart=/var/www/html/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:5000 app:app

[Install]
WantedBy=multi-user.target
EOF

echo "🔁 Reloading systemd and starting Gunicorn..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl start gunicorn
sudo systemctl enable gunicorn

echo "✅ All steps completed! Your Techmspire app is now live and running."
