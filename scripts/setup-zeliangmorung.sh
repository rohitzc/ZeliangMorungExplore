#!/bin/bash

# ZeliangMorung Explore - Complete Setup Script
# This script sets up SSL certificate, Apache configuration, and starts the application with PM2
# Domain: zeliangmorung.com
# IP: 100.31.46.250

set -e

echo "🚀 ZeliangMorung Explore - Complete Setup"
echo "=========================================="

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

# Configuration
DOMAIN="zeliangmorung.com"
IP="100.31.46.250"
EMAIL="rohit@zeliangcodetech.com"
LETSENCRYPT_DIR="/etc/letsencrypt/live/$DOMAIN"
CERT_FILE="$LETSENCRYPT_DIR/fullchain.pem"
KEY_FILE="$LETSENCRYPT_DIR/privkey.pem"

# Apache Configuration
APACHE_CONF_FILE="/etc/apache2/sites-available/zeliangmorung.conf"
APACHE_ENABLED_FILE="/etc/apache2/sites-enabled/zeliangmorung.conf"
VHOSTS_DIR="/etc/apache2/sites-available"

# Project directory - get script directory first
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Get port from .envdev file (defaults to 5000 if not found)
if [ -f "$PROJECT_DIR/.envdev" ]; then
    PORT=$(grep -E "^PORT=" "$PROJECT_DIR/.envdev" | cut -d'=' -f2 | tr -d '[:space:]' || echo "5000")
else
    PORT="5000"
fi

echo "📋 Configuration:"
echo "   Domain: $DOMAIN"
echo "   IP: $IP"
echo "   Email: $EMAIL"
echo "   Application Port: $PORT"
echo "   Project Directory: $PROJECT_DIR"
echo ""

# Function to handle port 80 conflicts
handle_port_conflicts() {
    echo "🔍 Checking for port 80 conflicts..."
    if netstat -tlnp 2>/dev/null | grep -q ":80 " || ss -tlnp 2>/dev/null | grep -q ":80 "; then
        echo "⚠️  Port 80 is already in use. Stopping conflicting services..."
        
        # Try to stop Apache if running
        if systemctl is-active --quiet apache2 2>/dev/null; then
            echo "🛑 Stopping Apache..."
            systemctl stop apache2
        fi
        
        # Try to stop nginx if running
        if systemctl is-active --quiet nginx 2>/dev/null; then
            echo "🛑 Stopping Nginx..."
            systemctl stop nginx
        fi
        
        # Try Bitnami if exists
        if [ -f "/opt/bitnami/ctlscript.sh" ]; then
            echo "🛑 Stopping Bitnami services..."
            /opt/bitnami/ctlscript.sh stop
        fi
        
        sleep 2
        echo "✅ Port 80 should now be available"
    else
        echo "✅ Port 80 is available"
    fi
}

# Function to check and install dependencies
install_dependencies() {
    echo "📦 Checking and installing dependencies..."
    
    # Check for required packages and install if missing
    local need_install=0
    
    if ! command -v certbot &> /dev/null; then
        echo "📦 Installing certbot..."
        apt update
        apt install -y certbot python3-certbot-apache
        need_install=1
    fi
    
    if ! command -v openssl &> /dev/null; then
        echo "📦 Installing openssl..."
        apt update
        apt install -y openssl
        need_install=1
    fi
    
    if ! command -v apache2 &> /dev/null; then
        echo "📦 Installing apache2..."
        apt update
        apt install -y apache2
        need_install=1
    fi
    
    if ! command -v node &> /dev/null; then
        echo "📦 Installing nodejs..."
        apt update
        apt install -y nodejs
        need_install=1
    fi
    
    if ! command -v npm &> /dev/null; then
        echo "📦 Installing npm..."
        apt update
        apt install -y npm
        need_install=1
    fi
    
    if ! command -v pm2 &> /dev/null; then
        echo "📦 Installing PM2..."
        if command -v npm &> /dev/null; then
            npm install -g pm2
        else
            echo "❌ npm not available, cannot install PM2"
            return 1
        fi
        need_install=1
    fi
    
    if [ $need_install -eq 0 ]; then
        echo "✅ All dependencies are already installed"
    else
        echo "✅ Dependencies installation complete"
    fi
}

# Function to enable Apache modules
enable_apache_modules() {
    echo "📦 Enabling required Apache modules..."
    
    # Enable modules one by one
    for module in ssl rewrite headers proxy proxy_http proxy_wstunnel; do
        if ! a2enmod "$module" 2>/dev/null; then
            echo "⚠️  Warning: Could not enable module $module"
        else
            echo "✅ Module $module enabled"
        fi
    done
}

# Function to setup SSL certificate
setup_ssl() {
    echo ""
    echo "🔒 Step 1: Setting up SSL Certificate"
    echo "======================================"
    
    # Check if certificate already exists
    if [ -f "$CERT_FILE" ]; then
        echo "✅ SSL certificate already exists at $CERT_FILE"
        echo "🔍 Validating certificate..."
        if openssl x509 -checkend 86400 -noout -in "$CERT_FILE" 2>/dev/null; then
            echo "✅ Certificate is valid and not expiring soon"
            return 0
        else
            echo "⚠️  Certificate exists but may be expiring soon or invalid"
            echo "🔄 Attempting to renew..."
        fi
    fi
    
    # Install certbot if not available
    if ! command -v certbot &> /dev/null; then
        echo "📦 Installing certbot..."
        apt update
        apt install -y certbot python3-certbot-apache
    fi
    
    # Handle port conflicts
    handle_port_conflicts
    
    # Get certificate using standalone mode
    echo "🌐 Obtaining Let's Encrypt certificate for $DOMAIN..."
    echo "⚠️  IMPORTANT: Ensure $DOMAIN points to $IP and DNS propagation is complete"
    echo ""
    
    certbot certonly --standalone \
        --non-interactive \
        --agree-tos \
        --email "$EMAIL" \
        --no-eff-email \
        -d "$DOMAIN"
    
    if [ $? -eq 0 ] && [ -f "$CERT_FILE" ]; then
        echo "✅ SSL certificate obtained successfully"
        echo "   Certificate: $CERT_FILE"
        echo "   Key: $KEY_FILE"
        return 0
    else
        echo "❌ Failed to obtain SSL certificate"
        return 1
    fi
}

# Function to create Apache configuration
create_apache_config() {
    echo ""
    echo "🌐 Step 2: Configuring Apache"
    echo "============================="
    
    # Enable required modules
    enable_apache_modules
    
    # Create Apache configuration
    echo "📝 Creating Apache configuration..."
    cat > "$APACHE_CONF_FILE" <<EOF
# ZeliangMorung Explore Apache Reverse Proxy Configuration
# Domain: $DOMAIN
# IP: $IP

<VirtualHost *:80>
    ServerName $DOMAIN
    ServerAlias $IP
    
    # Redirect all HTTP traffic to HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</VirtualHost>

<VirtualHost *:443>
    ServerName $DOMAIN
    ServerAlias $IP
    
    # SSL Configuration (Let's Encrypt)
    SSLEngine on
    SSLCertificateFile $CERT_FILE
    SSLCertificateKeyFile $KEY_FILE
    
    # Modern SSL Security Configuration
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder on
    SSLSessionTickets off
    
    # Security Headers
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline' https://unpkg.com; img-src 'self' data: https:; font-src 'self' https:; connect-src 'self' https:;"
    
    # Reverse Proxy Configuration
    ProxyPreserveHost On
    ProxyRequests Off
    
    # Forward headers to the backend application
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-For "%{REMOTE_ADDR}s"
    
    # Proxy requests to the Node.js application
    ProxyPass / http://127.0.0.1:$PORT/
    ProxyPassReverse / http://127.0.0.1:$PORT/
    
    # WebSocket support
    ProxyPass /ws/ ws://127.0.0.1:$PORT/ws/
    ProxyPassReverse /ws/ ws://127.0.0.1:$PORT/ws/
    
    # Logging
    ErrorLog \${APACHE_LOG_DIR}/zeliangmorung_error.log
    CustomLog \${APACHE_LOG_DIR}/zeliangmorung_access.log combined
</VirtualHost>
EOF
    
    echo "✅ Apache configuration created at $APACHE_CONF_FILE"
    
    # Enable the site
    echo "🔗 Enabling Apache site..."
    if [ -L "$APACHE_ENABLED_FILE" ]; then
        echo "✅ Site already enabled"
    else
        a2ensite zeliangmorung.conf
        echo "✅ Site enabled"
    fi
    
    # Test Apache configuration
    echo "🔍 Testing Apache configuration..."
    if apache2ctl configtest; then
        echo "✅ Apache configuration is valid"
    else
        echo "❌ Apache configuration test failed"
        return 1
    fi
    
    # Restart Apache
    echo "🔄 Restarting Apache..."
    systemctl restart apache2
    
    if systemctl is-active --quiet apache2; then
        echo "✅ Apache is running successfully"
        return 0
    else
        echo "❌ Failed to start Apache"
        systemctl status apache2
        return 1
    fi
}

# Function to build and start application with PM2
start_application() {
    echo ""
    echo "🚀 Step 3: Building and Starting Application with PM2"
    echo "====================================================="
    
    cd "$PROJECT_DIR"
    
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js is not installed"
        return 1
    fi
    
    # Check if PM2 is installed
    if ! command -v pm2 &> /dev/null; then
        echo "📦 Installing PM2..."
        npm install -g pm2
    fi
    
    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing npm dependencies..."
        npm install
    fi
    
    # Build the application
    echo "🔨 Building application..."
    npm run build
    
    if [ $? -ne 0 ]; then
        echo "❌ Build failed"
        return 1
    fi
    
    # Check if application is already running in PM2
    if pm2 list | grep -q "zeliangmorung"; then
        echo "🔄 Application already running in PM2, restarting..."
        pm2 restart zeliangmorung
    else
        echo "🚀 Starting application with PM2..."
        
        # Create PM2 ecosystem file
        cat > "$PROJECT_DIR/ecosystem.config.js" <<EOF
module.exports = {
  apps: [{
    name: 'zeliangmorung',
    script: 'dist/index.js',
    cwd: '$PROJECT_DIR',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: $PORT
    },
    error_file: '$PROJECT_DIR/logs/pm2-error.log',
    out_file: '$PROJECT_DIR/logs/pm2-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G'
  }]
};
EOF
        
        # Create logs directory
        mkdir -p "$PROJECT_DIR/logs"
        
        # Start with PM2
        pm2 start ecosystem.config.js
        pm2 save
        pm2 startup
    fi
    
    # Wait a moment for the app to start
    sleep 2
    
    # Check if application is running
    if pm2 list | grep -q "zeliangmorung.*online"; then
        echo "✅ Application is running successfully"
        echo ""
        echo "📊 PM2 Status:"
        pm2 list
        return 0
    else
        echo "❌ Application failed to start"
        pm2 logs zeliangmorung --lines 20
        return 1
    fi
}

# Main execution
main() {
    echo ""
    echo "Starting setup process..."
    echo ""
    
    # Install dependencies
    if ! install_dependencies; then
        echo "❌ Failed to install dependencies"
        exit 1
    fi
    
    # Step 1: Setup SSL
    if ! setup_ssl; then
        echo "❌ SSL setup failed"
        exit 1
    fi
    
    # Step 2: Configure Apache
    if ! create_apache_config; then
        echo "❌ Apache configuration failed"
        exit 1
    fi
    
    # Step 3: Start application
    if ! start_application; then
        echo "❌ Application startup failed"
        exit 1
    fi
    
    echo ""
    echo "✅ Setup Complete!"
    echo "=================="
    echo ""
    echo "🌐 Your application is now accessible at:"
    echo "   HTTPS: https://$DOMAIN"
    echo "   HTTPS: https://$IP"
    echo ""
    echo "📝 Useful commands:"
    echo "   - View PM2 logs: pm2 logs zeliangmorung"
    echo "   - Restart app: pm2 restart zeliangmorung"
    echo "   - Stop app: pm2 stop zeliangmorung"
    echo "   - View Apache logs: tail -f /var/log/apache2/zeliangmorung_error.log"
    echo "   - Test Apache config: apache2ctl configtest"
    echo "   - Restart Apache: systemctl restart apache2"
    echo ""
}

# Run main function
main

