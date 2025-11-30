#!/bin/bash

# HAWA API Apache Reverse Proxy Setup Script
# This script sets up Apache as a reverse proxy for the Node.js API

set -e

echo "🌐 HAWA API Apache Reverse Proxy Setup"
echo "======================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

# Function to handle port 80 conflicts
handle_port_conflicts() {
    echo "🔍 Checking for port 80 conflicts..."
    if netstat -tlnp | grep -q ":80 "; then
        echo "⚠️  Port 80 is already in use. Stopping conflicting services..."
        echo "🛑 Stopping Bitnami services..."
        /opt/bitnami/ctlscript.sh stop
        echo "✅ Bitnami services stopped"
        sleep 2
    else
        echo "✅ Port 80 is available"
    fi
}

# Configuration for Bitnami Apache
CONF_FILE="/opt/bitnami/apache/conf/vhosts/hawa-api-proxy.conf"
HTTPD_CONF="/opt/bitnami/apache/conf/httpd.conf"
VHOSTS_DIR="/opt/bitnami/apache/conf/vhosts"

echo "📋 Configuration:"
echo "   Apache Config: $CONF_FILE"
echo "   Main Config: $HTTPD_CONF"
echo "   Node.js API Port: 3000 (HTTP mode - Apache handles SSL)"
echo "   Domain: api.npcb.in"
echo "   SSL Certificates: Let's Encrypt"
echo ""

# Check if required modules are loaded
echo "📦 Checking required Apache modules..."
REQUIRED_MODULES=("ssl_module" "rewrite_module" "headers_module" "proxy_module" "proxy_http_module")
OPTIONAL_MODULES=("proxy_wstunnel_module")

# Check required modules
for module in "${REQUIRED_MODULES[@]}"; do
    if ! /opt/bitnami/apache/bin/httpd -M | grep -q "$module"; then
        echo "❌ Required module $module not loaded. Please enable it in $HTTPD_CONF"
        echo "   Add: LoadModule ${module} modules/mod_${module}.so"
        echo "   Then restart Apache: /opt/bitnami/ctlscript.sh restart"
        exit 1
    else
        echo "✅ Module $module is loaded"
    fi
done

# Check optional modules
for module in "${OPTIONAL_MODULES[@]}"; do
    if ! /opt/bitnami/apache/bin/httpd -M | grep -q "$module"; then
        echo "⚠️  Optional module $module not loaded (WebSocket support disabled)"
        echo "   To enable WebSocket support, add to $HTTPD_CONF:"
        echo "   LoadModule ${module} modules/mod_${module}.so"
    else
        echo "✅ Module $module is loaded (WebSocket support enabled)"
    fi
done

# Create vhosts directory if it doesn't exist
echo "📁 Setting up Apache configuration..."
if [ ! -d "$VHOSTS_DIR" ]; then
    echo "📂 Creating vhosts directory: $VHOSTS_DIR"
    mkdir -p "$VHOSTS_DIR"
fi

# Copy configuration file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
echo "📋 Copying configuration from: $PROJECT_ROOT/apache-api-proxy.conf"
echo "📋 To: $CONF_FILE"
cp "$PROJECT_ROOT/apache-api-proxy.conf" "$CONF_FILE"

# Ensure vhosts are included in main httpd.conf
echo "🔧 Ensuring vhosts are included in main configuration..."
if ! grep -q "Include.*vhosts" "$HTTPD_CONF"; then
    echo "📝 Adding vhosts include to $HTTPD_CONF"
    echo "" >> "$HTTPD_CONF"
    echo "# Include virtual hosts" >> "$HTTPD_CONF"
    echo "Include $VHOSTS_DIR/*.conf" >> "$HTTPD_CONF"
else
    echo "✅ Vhosts include already present in $HTTPD_CONF"
fi

# Test Apache configuration
echo "🔍 Testing Apache configuration..."
/opt/bitnami/apache/bin/httpd -t

if [ $? -eq 0 ]; then
    echo "✅ Apache configuration is valid"
    
    # Handle port conflicts before restarting
    handle_port_conflicts
    
    # Restart Apache using Bitnami control script
    echo "🔄 Restarting Apache..."
    sudo /opt/bitnami/ctlscript.sh restart
    
    # Check if Apache is running
    if sudo /opt/bitnami/ctlscript.sh status | grep -q "apache.*running"; then
        echo "✅ Apache is running successfully"
        
        # Restart other Bitnami services if needed
        echo "🔄 Restarting other Bitnami services..."
        /opt/bitnami/ctlscript.sh restart
    else
        echo "❌ Failed to start Apache"
        sudo /opt/bitnami/ctlscript.sh status
        exit 1
    fi
    
    echo "✅ Apache reverse proxy setup complete!"
    echo ""
    echo "🌐 Your API is now accessible at:"
    echo "   HTTP: http://api.npcb.in (redirects to HTTPS)"
    echo "   HTTPS: https://api.npcb.in"
    echo "   IP: https://15.207.9.17"
    echo ""
    echo "🔧 To start your Node.js API:"
    echo "   npm run start:http"
    echo ""
    echo "📝 Important Notes:"
    echo "   - Node.js API runs on port 3000 (HTTP mode)"
    echo "   - Apache handles SSL termination"
    echo "   - Make sure Let's Encrypt certificates are set up first"
    echo "   - Run: npm run setup:ssl (if not done already)"
    echo ""
    echo "🔍 Useful Bitnami Apache commands:"
    echo "   - Test config: /opt/bitnami/apache/bin/httpd -t"
    echo "   - Restart services: /opt/bitnami/ctlscript.sh restart"
    echo "   - Check status: /opt/bitnami/ctlscript.sh status"
    echo "   - View logs: tail -f /opt/bitnami/apache/logs/error_log"
    echo "   - View HAWA API logs: tail -f /opt/bitnami/apache/logs/hawa-api_error.log"
    
else
    echo "❌ Apache configuration test failed"
    echo "🔧 Please check the configuration and try again"
    echo "💡 Make sure all required modules are loaded in $HTTPD_CONF"
    exit 1
fi
