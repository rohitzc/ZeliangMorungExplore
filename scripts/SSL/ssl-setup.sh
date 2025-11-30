#!/bin/bash

# HAWA API SSL Manager
# Comprehensive SSL certificate management script

set -e

echo "🔒 HAWA API SSL Manager"
echo "======================="

# Configuration
DOMAIN="api.npcb.in"
EMAIL="rohit@zeliangcodetech.com"
LETSENCRYPT_DIR="/etc/letsencrypt/live/$DOMAIN"
CERT_FILE="$LETSENCRYPT_DIR/fullchain.pem"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

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

# Function to check and install all SSL dependencies
install_ssl_dependencies() {
    echo "📦 Checking and installing SSL dependencies..."
    
    local missing_packages=()
    
    # Check for required packages
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
    
    # Install missing packages
    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo "📦 Installing missing packages: ${missing_packages[*]}"
        sudo apt update
        sudo apt install -y "${missing_packages[@]}"
        
        # Verify installation
        local failed_packages=()
        for package in "${missing_packages[@]}"; do
            case $package in
                "certbot")
                    if ! command -v certbot &> /dev/null; then
                        failed_packages+=("certbot")
                    fi
                    ;;
                "openssl")
                    if ! command -v openssl &> /dev/null; then
                        failed_packages+=("openssl")
                    fi
                    ;;
                "curl")
                    if ! command -v curl &> /dev/null; then
                        failed_packages+=("curl")
                    fi
                    ;;
                "net-tools")
                    if ! command -v netstat &> /dev/null; then
                        failed_packages+=("net-tools")
                    fi
                    ;;
                "systemd")
                    if ! command -v systemctl &> /dev/null; then
                        failed_packages+=("systemd")
                    fi
                    ;;
            esac
        done
        
        if [ ${#failed_packages[@]} -gt 0 ]; then
            echo "❌ Failed to install: ${failed_packages[*]}"
            return 1
        fi
        
        echo "✅ All SSL dependencies installed successfully"
    else
        echo "✅ All SSL dependencies are already installed"
    fi
    
    # Show versions
    echo "📋 Installed SSL Tools:"
    if command -v certbot &> /dev/null; then
        echo "   Certbot: $(certbot --version 2>/dev/null || echo 'installed')"
    fi
    if command -v openssl &> /dev/null; then
        echo "   OpenSSL: $(openssl version 2>/dev/null || echo 'installed')"
    fi
    if command -v curl &> /dev/null; then
        echo "   cURL: $(curl --version 2>/dev/null | head -1 || echo 'installed')"
    fi
    
    return 0
}

# Function to create SSL directories
# SSL directories are no longer needed - using Let's Encrypt paths directly

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

# Function to setup Let's Encrypt
setup_letsencrypt() {
    echo "🌐 Setting up Let's Encrypt certificate..."
    echo "⚠️  IMPORTANT: Let's Encrypt requires a domain name!"
    echo "   IP addresses (like 15.207.9.17) are not supported"
    echo ""
    echo "📋 Requirements:"
    echo "   1. Domain name: $DOMAIN"
    echo "   2. Domain must point to 15.207.9.17"
    echo "   3. DNS propagation complete"
    echo ""
    
    read -p "Continue with Let's Encrypt setup? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        echo "⏭️  Skipping Let's Encrypt setup"
        return 1
    fi
    
    # Check if certbot is installed
    if ! command -v certbot &> /dev/null; then
        echo "❌ Certbot not found. Installing..."
        echo "📦 Installing certbot and dependencies..."
        sudo apt update && sudo apt install -y certbot openssl curl
        if ! command -v certbot &> /dev/null; then
            echo "❌ Failed to install certbot. Please install manually."
            return 1
        fi
        echo "✅ Certbot installed successfully"
    fi
    
    # Stop services on port 80
    handle_port_conflicts
    
    # Get certificate
    echo "🔄 Getting Let's Encrypt certificate..."
    sudo certbot certonly --standalone \
        --email $EMAIL \
        --agree-tos \
        --no-eff-email \
        --domains $DOMAIN
    
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

# Function to setup existing certificates
setup_existing_certificates() {
    echo "📁 Setting up existing certificates..."
    echo "Please copy your certificate to:"
    echo "   Certificate: $CERT_FILE"
    echo ""
    echo "📋 Certificate requirements:"
    echo "   - Must be valid for IP: 15.207.9.17 or domain name"
    echo "   - Must be in PEM format"
    echo "   - Certificate chain should be complete"
    echo ""
    
    read -p "Press Enter when certificates are in place..."
    
    # Validate certificate using openssl
    if sudo openssl x509 -dates -noout -in "$CERT_FILE" 2>/dev/null; then
        echo "✅ Certificate is valid and accessible"
        return 0
    else
        echo "❌ Certificate is invalid or not accessible"
        return 1
    fi
}


# Function to validate certificates
validate_certificates() {
    echo "🔍 Validating SSL certificate..."
    
    # Validate certificate using openssl
    if sudo openssl x509 -dates -noout -in "$CERT_FILE" 2>/dev/null; then
        echo "✅ Certificate is valid and accessible"
    else
        echo "❌ Certificate is invalid or not accessible"
        return 1
    fi
    
    # Show certificate information
    echo ""
    echo "📋 Certificate Information:"
    echo "=========================="
    openssl x509 -in "$CERT_FILE" -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:)" | head -4
    
    return 0
}

# Function to renew certificate
renew_certificate() {
    echo "🔄 Renewing certificate..."
    
    if [ ! -f "$CERT_FILE" ]; then
        echo "❌ No certificate found to renew"
        return 1
    fi
    
    # Check if it's a Let's Encrypt certificate
    if openssl x509 -in "$CERT_FILE" -text -noout | grep -q "Let's Encrypt"; then
        echo "🌐 Renewing Let's Encrypt certificate..."
        
        # Stop services on port 80
        handle_port_conflicts
        
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
    else
        echo "❌ This is not a Let's Encrypt certificate"
        echo "   Manual renewal required for other certificate types"
        return 1
    fi
}

# Main menu
show_menu() {
    echo ""
    echo "📋 SSL Management Options:"
    echo "1. Setup SSL (Let's Encrypt)"
    echo "2. Setup SSL (Existing Certificates)"
    echo "3. Validate Certificates"
    echo "4. Renew Certificate (Standard)"
    echo "5. Renew Certificate (Zero-Downtime)"
    echo "6. Check Certificate Status"
    echo "7. Exit"
    echo ""
}

# Main execution
main() {
    cd "$PROJECT_DIR"
    
    # Install SSL dependencies first
    echo "🔍 Checking SSL dependencies..."
    if ! install_ssl_dependencies; then
        echo "❌ Failed to install SSL dependencies"
        exit 1
    fi
    
    echo ""
    echo "🔍 Validating certificate..."
    if validate_certificate; then
        echo "✅ Certificate is valid - no action needed"
    else
        echo "❌ Certificate is invalid or not found"
        echo "🔄 Attempting to renew certificate..."
        if renew_certificate; then
            echo "✅ Certificate renewed successfully"
        else
            echo "❌ Certificate renewal failed"
            echo "🔄 Attempting to regenerate certificate..."
            if setup_letsencrypt; then
                echo "✅ Certificate regenerated successfully"
            else
                echo "❌ Certificate regeneration failed"
                echo "🔧 Please check your domain configuration and try again"
            fi
        fi
    fi
    
    while true; do
        show_menu
        read -p "Choose an option (1-7): " choice
        
        case $choice in
            1)
                setup_letsencrypt
                ;;
            2)
                setup_existing_certificates
                ;;
            3)
                validate_certificates
                ;;
            4)
                renew_certificate
                ;;
            5)
                echo "🚀 Running zero-downtime certificate renewal..."
                chmod +x ../SSL/zero-downtime-renewal.sh
                ../SSL/zero-downtime-renewal.sh
                ;;
            6)
                validate_certificate
                ;;
            7)
                echo "👋 Goodbye!"
                exit 0
                ;;
            *)
                echo "❌ Invalid option"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main
