#!/bin/bash

# HAWA API Let's Encrypt SSL Setup Script
# This script intelligently manages Let's Encrypt SSL certificates

set -e

echo "🌐 HAWA API Let's Encrypt SSL Setup"
echo "===================================="

# Configuration
DOMAIN="api.npcb.in"  # You need a domain name for Let's Encrypt
EMAIL="rohit@zeliangcodetech.com"
LETSENCRYPT_DIR="/etc/letsencrypt/live/$DOMAIN"
CERT_FILE="$LETSENCRYPT_DIR/fullchain.pem"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

echo "📋 Configuration:"
echo "   Domain: $DOMAIN"
echo "   Email: $EMAIL"
echo "   Let's Encrypt Directory: $LETSENCRYPT_DIR"
echo "   Certificate File: $CERT_FILE"
echo ""

# Function to validate certificate using openssl
validate_certificate() {
    echo "🔍 Validating certificate with openssl..."
    if sudo openssl x509 -dates -noout -in "$CERT_FILE" 2>/dev/null; then
        echo "✅ Certificate is valid"
        echo "📋 Certificate dates:"
        sudo openssl x509 -dates -noout -in "$CERT_FILE"
        return 0
    else
        echo "❌ Certificate is invalid or not found"
        return 1
    fi
}

# Function to check if certbot is installed
check_certbot_installation() {
    if command -v certbot &> /dev/null; then
        echo "✅ Certbot is already installed"
        return 0
    else
        echo "❌ Certbot is not installed"
        return 1
    fi
}

# Function to install certbot
install_certbot() {
    echo "📦 Installing certbot..."
    
    # Update package list
    apt update
    
    # Install certbot
    apt install -y certbot
    
    # Verify installation
    if command -v certbot &> /dev/null; then
        echo "✅ Certbot installed successfully"
        return 0
    else
        echo "❌ Failed to install certbot"
        return 1
    fi
}

# Function to generate new certificate
generate_certificate() {
    echo "🔄 Generating new Let's Encrypt certificate..."
    
    # Stop services on port 80
    systemctl stop nginx 2>/dev/null || true
    systemctl stop httpd 2>/dev/null || true
    systemctl stop apache2 2>/dev/null || true
    
    # Generate certificate
    certbot certonly --standalone \
        --non-interactive \
        --agree-tos \
        --email "$EMAIL" \
        --domains "$DOMAIN"
    
    if [ $? -eq 0 ]; then
        echo "✅ Let's Encrypt certificate obtained"
        
        # Validate certificate using openssl
        if sudo openssl x509 -dates -noout -in "$CERT_FILE" 2>/dev/null; then
            echo "✅ Certificate is valid and accessible"
            echo "   Certificate: $CERT_FILE"
            return 0
        else
            echo "❌ Certificate is invalid or not accessible"
            return 1
        fi
    else
        echo "❌ Let's Encrypt certificate failed"
        return 1
    fi
}

# Function to renew certificate
renew_certificate() {
    echo "🔄 Renewing Let's Encrypt certificate..."
    
    # Stop services on port 80
    systemctl stop nginx 2>/dev/null || true
    systemctl stop httpd 2>/dev/null || true
    systemctl stop apache2 2>/dev/null || true
    
    # Renew certificate
    sudo certbot renew --force-renewal
    
    if [ $? -eq 0 ]; then
        # Validate renewed certificate using openssl
        if sudo openssl x509 -dates -noout -in "$CERT_FILE" 2>/dev/null; then
            echo "✅ Certificate renewed successfully"
            echo "   Certificate: $CERT_FILE"
            return 0
        else
            echo "❌ Renewed certificate is invalid or not accessible"
            return 1
        fi
    else
        echo "❌ Certificate renewal failed"
        return 1
    fi
}

# Function to show certificate info
show_certificate_info() {
    echo ""
    echo "📋 Certificate Information:"
    echo "=========================="
    sudo openssl x509 -in "$CERT_FILE" -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:)" | head -4
    echo ""
}

# Main execution
echo "🔍 Checking certbot installation..."
if ! check_certbot_installation; then
    echo "📦 Installing certbot..."
    if ! install_certbot; then
        echo "❌ Failed to install certbot"
        exit 1
    fi
fi

echo ""
echo "🔍 Validating certificate..."

# Validate certificate using openssl
if validate_certificate; then
    echo "✅ Certificate is valid - no action needed"
    echo ""
    echo "🎉 Certificate is ready to use."
    echo "🔧 To start the HTTPS server, run:"
    echo "   npm run start:https"
    exit 0
else
    echo "❌ Certificate is invalid or not found"
    echo "🔄 Attempting to renew certificate..."
    if renew_certificate; then
        echo "✅ Certificate renewed successfully"
        echo ""
        echo "🔧 To start the HTTPS server, run:"
        echo "   npm run start:https"
        exit 0
    else
        echo "❌ Certificate renewal failed"
        echo "🔄 Attempting to regenerate certificate..."
        if generate_certificate; then
            echo "✅ Certificate regenerated successfully"
            echo ""
            echo "🔧 To start the HTTPS server, run:"
            echo "   npm run start:https"
            exit 0
        else
            echo "❌ Certificate regeneration failed"
            echo "🔧 Please check your domain configuration and try again"
            exit 1
        fi
    fi
fi