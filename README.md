# # Ecomm App — Project Guide

> Light-weight e-commerce Flask application with Nginx reverse proxy and MySQL backend.

---

## Project Overview

This repository contains the Techmspire / Ecomm Flask application. The app serves HTML pages from the `api/` folder, exposes REST endpoints under `/api/*`, and stores persistent data in a MySQL database.

* **Framework**: Flask (Gunicorn for production)
* **Reverse proxy**: Nginx
* **Database**: MySQL
* **OS targeted**: Ubuntu 24.04

---

## Folder layout (as deployed on VM)

```
/var/www/html/
├── app.py
├── db.sql
├── requirements.txt
├── venv/                     # Python virtual environment (auto-generated)
└── api/                      # Frontend HTML files and static assets
    ├── cart.html
    ├── contact.html
    ├── home.html
    ├── index.html
    ├── logout.html
    ├── order-history.html
    ├── order.html
    ├── products.html
    ├── signup.html
    └── images/               # Static image assets
```

---

## Ports to open

* **MySQL**: `3306`
* **Nginx / HTTP**: `80`
* **Flask (Gunicorn)**: `5000` (bound to `127.0.0.1:5000` by default)

---

## Quick setup (manual)

> Run these on the Ubuntu 24.04 VM. Commands assume you have `sudo` access.

```bash
# update system
sudo apt update && sudo apt upgrade -y

# install dependencies
sudo apt install -y python3-pip python3-venv nginx mysql-server vsftpd

# set permissions for web root
sudo chown -R ubuntu:ubuntu /var/www/html
sudo chmod -R 755 /var/www/html

cd /var/www/html
```

### Create `requirements.txt`

Create `requirements.txt` with:

```
Flask
mysql-connector-python
gunicorn
```

Install virtualenv and dependencies:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## Database setup

1. Secure MySQL installation:

```bash
sudo mysql_secure_installation
```

2. Import the supplied `db.sql` and create database & user:

```bash
# start mysql if not running
sudo systemctl start mysql

# import schema & seed data
sudo mysql -u root -p < /var/www/html/db.sql
```

> `db.sql` creates `ecommerce_db`, all necessary tables and sample data, and creates the MySQL user `sanket` with password `pass`.

Manual MySQL commands (examples):

```sql
USE ecommerce_db;
SHOW TABLES;
-- connect as app user
mysql -u sanket -p
```

---

## File deployment (copying files)

Example commands (adjust sources as needed):

```bash
mkdir -p /var/www/html/api
cp -r /path/to/frontend/*.html /var/www/html/api/
cp app.py /var/www/html/
cp db.sql /var/www/html/
```

---

## Run the Flask app (development / quick test)

Activate venv then run:

```bash
source /var/www/html/venv/bin/activate
python /var/www/html/app.py
# or run gunicorn directly
gunicorn --bind 127.0.0.1:5000 app:app
```

---

## Nginx configuration

Create `/etc/nginx/sites-available/ecomm-app.conf` with the following content:

```nginx
server {
    listen 80;
    server_name your_domain_or_ip;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /static/ {
        alias /var/www/html/api/;  # update path as needed
    }
}
```

Enable site and remove the default site:

```bash
sudo ln -s /etc/nginx/sites-available/ecomm-app.conf /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-available/default
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

---

## Systemd Gunicorn service

Create `/etc/systemd/system/gunicorn.service`:

```ini
[Unit]
Description=Gunicorn for ecomm-app Flask app
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/var/www/html
Environment="PATH=/var/www/html/venv/bin"
ExecStart=/var/www/html/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:5000 app:app

[Install]
WantedBy=multi-user.target
```

Reload systemd and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl start gunicorn
sudo systemctl enable gunicorn
```

---

## `app.py` (entrypoint)

* The Flask app uses `api/` as the `template_folder` and connects to MySQL using the `sanket` user.
* Default config connects to MySQL on `localhost` and expects database `ecommerce_db`.
* The app exposes routes for pages and REST APIs for login, product listing, cart, orders, and contact.

> The full `app.py` is included in the repository root. It starts the Flask app on `0.0.0.0:5000` when run directly.

---

## `db.sql`

`db.sql` contains:

* Database creation (`ecommerce_db`) and user creation (`sanket` / `pass`)
* Tables: `users`, `products`, `cart`, `orders`, `order_items`, `contacts`
* Sample users and a product catalog

---

## Single-click installation script

A `setup.sh` script is provided (or can be created) to perform the entire installation: update packages, install prerequisites, create venv, install requirements, secure MySQL, import `db.sql`, create Nginx config, enable site, and create + enable the Gunicorn systemd service.

> The project includes a verified example script. Review and run carefully (especially `mysql_secure_installation` and the `mysql -u root -p < db.sql` step which requires the MySQL root password).

---

## Useful commands & command history

A command history log is included in the repository (for reproducibility). Example useful commands:

```bash
# Check logs
sudo journalctl -u gunicorn -f
sudo journalctl -u nginx -f

# MySQL backup
docker exec -t <db_container> mysqldump -u root -p ecommerce_db > backup.sql

# Rebuild virtualenv
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## Troubleshooting

* **502 Bad Gateway from Nginx**: Ensure Gunicorn is running and bound to `127.0.0.1:5000` and that `WorkingDirectory` in the systemd service is correct. Check `sudo journalctl -u gunicorn`.
* **DB connection errors**: Check `db.sql` was imported and the user `sanket` exists with correct password. Verify the `DB_CONFIG` in `app.py`.
* **Static files not loading**: Confirm `location /static/` alias path and that files exist under `/var/www/html/api/`.
* **Permission issues writing uploads**: Check ownership and permissions of the uploads directory (owner `ubuntu` or appropriate user); adjust with `chown`/`chmod`.

---

## Next steps / Roadmap (suggested features)

* Add user-specific order history pages and admin panel
* Generate receipts/invoices with order breakdowns
* Add search and filtering on product pages
* Add authentication hashing (do not store plaintext passwords) — use `werkzeug.security` or `bcrypt`
* Dockerize the stack (Flask + Nginx + MySQL) using `docker-compose`
* Add HTTPS (Let's Encrypt) and image CDN for production

---


## License

Use and modify this project as needed. Review any third-party licenses for included libraries.

---

## Acknowledgements

Prepared for learning purpose — deployment and automation notes included.

