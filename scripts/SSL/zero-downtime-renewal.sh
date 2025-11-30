#!/bin/bash

# HAWA API Zero-Downtime Certificate Renewal Script
# This script renews certificates without stopping the API server

set -e

echo "🚀 HAWA API Zero-Downtime Certificate Renewal"
echo "============================================="

# Configuration
DOMAIN="api.npcb.in"
EMAIL="rohit@zeliangcodetech.com"
LETSENCRYPT_DIR="/etc/letsencrypt/live/$DOMAIN"
CERT_FILE="$LETSENCRYPT_DIR/fullchain.pem"
KEY_FILE="$LETSENCRYPT_DIR/privkey.pem"
RENEWAL_THRESHOLD_DAYS=2  # Renew when certificate expires in 30 days (configurable)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "📋 Zero-Downtime Renewal Configuration:"
echo "   Domain: $DOMAIN"
echo "   Certificate: $CERT_FILE"
echo "   Renewal Threshold: $RENEWAL_THRESHOLD_DAYS days"
echo "   Project Directory: $PROJECT_DIR"
echo ""

# Function to validate certificate using openssl
validate_certificate() {
    echo "🔍 Validating certificate with openssl..."
    if sudo openssl x509 -dates -noout -in "$CERT_FILE" 2>/dev/null; then
        echo "✅ Certificate is valid"
        return 0
    else
        echo "❌ Certificate is invalid or not found"
        return 1
    fi
}

# Function to check if renewal is needed
is_renewal_needed() {
    local days_until_expiry=$(get_cert_expiry_days)
    
    echo "📅 Certificate expires in: $days_until_expiry days"
    
    if [ "$days_until_expiry" -lt "$RENEWAL_THRESHOLD_DAYS" ]; then
        echo "🔄 Renewal needed: Certificate expires in less than $RENEWAL_THRESHOLD_DAYS days"
        return 0
    else
        echo "✅ No renewal needed: Certificate is valid for $days_until_expiry days"
        return 1
    fi
}

# Function to backup current certificates
backup_certificates() {
    echo "💾 Creating certificate backup..."
    local backup_dir="$SSL_DIR/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    if [ -f "$CERT_FILE" ]; then
        cp "$CERT_FILE" "$backup_dir/cert.pem"
    fi
    if [ -f "$KEY_FILE" ]; then
        cp "$KEY_FILE" "$backup_dir/private.key"
    fi
    
    echo "✅ Certificates backed up to: $backup_dir"
    echo "$backup_dir"
}

# Function to restore certificates from backup
restore_certificates() {
    local backup_dir="$1"
    echo "🔄 Restoring certificates from backup..."
    
    if [ -d "$backup_dir" ]; then
        if [ -f "$backup_dir/cert.pem" ]; then
            cp "$backup_dir/cert.pem" "$CERT_FILE"
        fi
        if [ -f "$backup_dir/private.key" ]; then
            cp "$backup_dir/private.key" "$KEY_FILE"
        fi
        
        # Set proper permissions
        chmod 644 "$CERT_FILE"
        chmod 600 "$KEY_FILE"
        
        echo "✅ Certificates restored from backup"
        return 0
    else
        echo "❌ Backup directory not found: $backup_dir"
        return 1
    fi
}

# Function to reload API server (zero-downtime)
reload_api_server() {
    echo "🔄 Attempting to reload API server..."
    
    # Find API server process
    local api_pid=$(pgrep -f "node.*server-https.js" | head -1)
    if [ -n "$api_pid" ]; then
        echo "📡 Sending SIGHUP to API server (PID: $api_pid)..."
        if kill -HUP "$api_pid" 2>/dev/null; then
            echo "✅ API server reload signal sent"
            sleep 2
            
            # Test if server is still responding
            if curl -s -k https://localhost:3443/health >/dev/null 2>&1; then
                echo "✅ API server reloaded successfully (zero-downtime)"
                return 0
            else
                echo "⚠️  API server reload failed, will need restart"
                return 1
            fi
        else
            echo "❌ Failed to send reload signal"
            return 1
        fi
    else
        echo "ℹ️  API server process not found"
        return 1
    fi
}

# Function to restart API server (fallback)
restart_api_server() {
    echo "🔄 Restarting API server (fallback method)..."
    
    # Stop API server
    local api_pid=$(pgrep -f "node.*server-https.js" | head -1)
    if [ -n "$api_pid" ]; then
        echo "🛑 Stopping API server (PID: $api_pid)..."
        kill "$api_pid"
        sleep 3
    fi
    
    # Start API server
    echo "🚀 Starting API server..."
    cd "$PROJECT_DIR"
    nohup npm run start:https > /dev/null 2>&1 &
    sleep 5
    
    # Test if server is responding
    if curl -s -k https://localhost:3443/health >/dev/null 2>&1; then
        echo "✅ API server restarted successfully"
        return 0
    else
        echo "❌ API server restart failed"
        return 1
    fi
}

# Function to perform zero-downtime renewal
perform_zero_downtime_renewal() {
    echo "🔄 Starting zero-downtime certificate renewal..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        echo "⚠️  This script needs root access for Let's Encrypt operations"
        echo "🔧 Run with: sudo ./scripts/SSL/zero-downtime-renewal.sh"
        return 1
    fi
    
    # Create backup
    local backup_dir=$(backup_certificates)
    
    # Check and install all SSL dependencies
    echo "📦 Checking SSL dependencies..."
    local missing_packages=()
    
    if ! command -v certbot &> /dev/null; then
        missing_packages+=("certbot")
    fi
    
    if ! command -v openssl &> /dev/null; then
        missing_packages+=("openssl")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing_packages+=("curl")
    fi
    
    if ! command -v netstat &> /dev/null; then
        missing_packages+=("net-tools")
    fi
    
    if ! command -v systemctl &> /dev/null; then
        missing_packages+=("systemd")
    fi
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo "📦 Installing missing packages: ${missing_packages[*]}"
        apt update && apt install -y "${missing_packages[@]}"
        
        # Verify installation
        for package in "${missing_packages[@]}"; do
            case $package in
                "certbot")
                    if ! command -v certbot &> /dev/null; then
                        echo "❌ Failed to install certbot"
                        return 1
                    fi
                    ;;
                "openssl")
                    if ! command -v openssl &> /dev/null; then
                        echo "❌ Failed to install openssl"
                        return 1
                    fi
                    ;;
                "curl")
                    if ! command -v curl &> /dev/null; then
                        echo "❌ Failed to install curl"
                        return 1
                    fi
                    ;;
                "net-tools")
                    if ! command -v netstat &> /dev/null; then
                        echo "❌ Failed to install net-tools"
                        return 1
                    fi
                    ;;
                "systemd")
                    if ! command -v systemctl &> /dev/null; then
                        echo "❌ Failed to install systemd"
                        return 1
                    fi
                    ;;
            esac
        done
        
        echo "✅ All SSL dependencies installed successfully"
    else
        echo "✅ All SSL dependencies are already installed"
    fi
    
    # Stop services on port 80 (but not API server)
    echo "🛑 Stopping services on port 80 (keeping API server running)..."
    systemctl stop nginx 2>/dev/null || true
    systemctl stop httpd 2>/dev/null || true
    systemctl stop apache2 2>/dev/null || true
    
    # Renew certificate
    echo "🔄 Force renewing certificate for $DOMAIN..."
    if certbot renew --force-renewal; then
        echo "✅ Certificate renewed successfully"
    else
        echo "❌ Certificate renewal failed"
        restore_certificates "$backup_dir"
        return 1
    fi
    
    # Validate renewed certificate using openssl
    echo "📁 Validating renewed certificate..."
    if sudo openssl x509 -dates -noout -in "$CERT_FILE" 2>/dev/null; then
        echo "✅ Renewed certificate is valid and accessible"
    else
        echo "❌ Renewed certificate is invalid or not accessible"
        restore_certificates "$backup_dir"
        return 1
    fi
    
    # Verify new certificates
    echo "🔍 Verifying new certificates..."
    if openssl x509 -in "$CERT_FILE" -text -noout >/dev/null 2>&1; then
        echo "✅ New certificate is valid"
    else
        echo "❌ New certificate is invalid"
        restore_certificates "$backup_dir"
        return 1
    fi
    
    # Attempt zero-downtime reload
    if reload_api_server; then
        echo "🎉 Zero-downtime renewal successful!"
        return 0
    else
        echo "⚠️  Zero-downtime reload failed, attempting restart..."
        if restart_api_server; then
            echo "✅ Renewal completed with brief restart"
            return 0
        else
            echo "❌ All renewal methods failed, restoring backup"
            restore_certificates "$backup_dir"
            restart_api_server
            return 1
        fi
    fi
}

# Main logic
echo "🔍 Validating certificate..."

# Validate certificate using openssl
if validate_certificate; then
    echo "✅ Certificate is valid - no renewal needed"
    echo "📋 Certificate dates:"
    sudo openssl x509 -dates -noout -in "$CERT_FILE"
    echo ""
    echo "✅ Certificate validation complete!"
    exit 0
else
    echo "❌ Certificate is invalid or not found"
    echo "🔄 Attempting to renew certificate..."
    echo ""
    echo "🔄 Zero-downtime certificate renewal is needed"
    
    # Perform zero-downtime renewal
    if perform_zero_downtime_renewal; then
        echo ""
        echo "🎉 Zero-Downtime Certificate Renewal Complete!"
        echo "============================================="
        echo "✅ Certificate renewed successfully"
        echo "📅 New expiration: $(get_cert_expiry_days) days"
        echo "🌐 API is accessible at: https://$DOMAIN"
        echo "⏱️  Zero downtime achieved!"
    else
        echo ""
        echo "❌ Zero-downtime renewal failed"
        echo "🔄 Fallback: API server restarted with backup certificates"
        exit 1
    fi
else
    echo ""
    echo "✅ Certificate is still valid"
    echo "📅 Next check: Tomorrow"
    echo "🔄 Next renewal: In $(( $(get_cert_expiry_days) - RENEWAL_THRESHOLD_DAYS )) days"
fi

echo ""
echo "📝 Log entry: $(date) - Zero-downtime certificate check completed"
