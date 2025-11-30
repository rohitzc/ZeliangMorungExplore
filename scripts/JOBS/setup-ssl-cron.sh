#!/bin/bash

# HAWA API SSL Certificate and Log Cleanup Cron Setup Script
# Sets up daily SSL monitoring and bi-weekly log cleanup cron jobs

set -e

echo "🔒 HAWA API SSL Certificate and Log Cleanup Cron Setup"
echo "======================================================"

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
CRON_LOG="$LOG_DIR/cron.log"

# SSL certificate monitoring schedule (daily at 2:00 AM)
SSL_MONITOR_SCHEDULE="0 2 * * *"

# Log cleanup schedule (every 2 weeks on Sunday at 3:00 AM)
LOG_CLEANUP_SCHEDULE="0 3 * * 0"

# Domain and certificate paths
DOMAIN="api.npcb.in"
CERT_FILE="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"

echo "📋 Configuration:"
echo "   Project Directory: $PROJECT_DIR"
echo "   Script Directory: $SCRIPT_DIR"
echo "   Log Directory: $LOG_DIR"
echo "   Certificate Log: $CRON_LOG"
echo "   Domain: $DOMAIN"
echo "   Certificate File: $CERT_FILE"
echo "   SSL Monitor Schedule: $SSL_MONITOR_SCHEDULE (daily at 2:00 AM)"
echo "   Log Cleanup Schedule: $LOG_CLEANUP_SCHEDULE (every 2 weeks on Sunday at 3:00 AM)"
echo ""

# Create logs directory
mkdir -p "$LOG_DIR"

# Function to add cron job
add_cron_job() {
    local schedule="$1"
    local command="$2"
    local description="$3"
    
    echo "📅 Adding cron job: $description"
    echo "   Schedule: $schedule"
    echo "   Command: $command"
    
    # Create temporary cron file
    local temp_cron=$(mktemp)
    
    # Get current crontab
    crontab -l 2>/dev/null > "$temp_cron" || touch "$temp_cron"
    
    # Remove existing HAWA API cron jobs (both SSL and log cleanup)
    grep -v "HAWA API - SSL certificate monitoring" "$temp_cron" | grep -v "HAWA API - Log cleanup" > "${temp_cron}.tmp" && mv "${temp_cron}.tmp" "$temp_cron"
    
    # Add new cron job
    echo "# $description" >> "$temp_cron"
    echo "$schedule $command" >> "$temp_cron"
    echo "" >> "$temp_cron"
    
    # Install new crontab
    crontab "$temp_cron"
    
    # Clean up
    rm "$temp_cron"
    
    echo "✅ Cron job added successfully"
}

# Function to verify SSL scripts exist
verify_ssl_scripts() {
    echo "🔍 Verifying SSL scripts exist..."
    
    local smart_renewal_script="$SCRIPT_DIR/SSL/smart-renewal.sh"
    local zero_downtime_script="$SCRIPT_DIR/SSL/zero-downtime-renewal.sh"
    local validate_script="$SCRIPT_DIR/SSL/validate-ssl.sh"
    
    if [ ! -f "$smart_renewal_script" ]; then
        echo "❌ Smart renewal script not found: $smart_renewal_script"
        return 1
    fi
    
    if [ ! -f "$zero_downtime_script" ]; then
        echo "❌ Zero downtime renewal script not found: $zero_downtime_script"
        return 1
    fi
    
    if [ ! -f "$validate_script" ]; then
        echo "❌ SSL validation script not found: $validate_script"
        return 1
    fi
    
    # Make scripts executable
    chmod +x "$smart_renewal_script"
    chmod +x "$zero_downtime_script"
    chmod +x "$validate_script"
    
    echo "✅ All SSL scripts found and made executable"
    return 0
}

# Function to test SSL certificate access
test_ssl_access() {
    echo "🔍 Testing SSL certificate access..."
    
    if sudo test -f "$CERT_FILE" && sudo test -r "$CERT_FILE"; then
        echo "✅ SSL certificate file is accessible: $CERT_FILE"
        
        # Test certificate validity
        if sudo openssl x509 -dates -noout -in "$CERT_FILE" 2>/dev/null; then
            echo "✅ SSL certificate is valid"
            return 0
        else
            echo "⚠️  SSL certificate exists but may be invalid"
            return 1
        fi
    else
        echo "⚠️  SSL certificate file not found or not accessible: $CERT_FILE"
        echo "ℹ️  This is normal for first-time setup. Certificate will be created when needed."
        return 1
    fi
}

# Main setup
echo "🔧 Setting up HAWA API SSL certificate monitoring..."

# Verify SSL scripts exist
if ! verify_ssl_scripts; then
    echo "❌ SSL scripts verification failed"
    exit 1
fi

# Test SSL certificate access (non-critical)
test_ssl_access

# Add SSL certificate monitoring cron job (daily at 2:00 AM)
add_cron_job \
    "$SSL_MONITOR_SCHEDULE" \
    "cd $PROJECT_DIR && sudo $SCRIPT_DIR/SSL/smart-renewal.sh >> $CRON_LOG 2>&1" \
    "HAWA API - SSL certificate monitoring (daily check and renewal if needed)"

# Add log cleanup cron job (every 2 weeks on Sunday at 3:00 AM)
add_cron_job \
    "$LOG_CLEANUP_SCHEDULE" \
    "cd $PROJECT_DIR && $SCRIPT_DIR/LOG/cleanup-logs.sh >> $CRON_LOG 2>&1" \
    "HAWA API - Log cleanup (removes logs older than 14 days)"

echo ""
echo "✅ SSL certificate monitoring and log cleanup setup completed successfully!"
echo ""
echo "📋 SSL certificate monitoring will:"
echo "   - Check certificate validity daily at 2:00 AM"
echo "   - Automatically renew certificate if it expires within 2 days"
echo "   - Use zero-downtime renewal when possible"
echo "   - Fall back to restart if zero-downtime fails"
echo "   - Log all operations to: $CRON_LOG"
echo ""
echo "📋 Log cleanup will:"
echo "   - Run every 2 weeks on Sunday at 3:00 AM"
echo "   - Remove log files older than 14 days"
echo "   - Clean both application and system logs"
echo "   - Log cleanup operations to: $CRON_LOG"
echo ""
echo "🔧 Manual SSL operations:"
echo "   Check certificate status: ./scripts/SSL/validate-ssl.sh"
echo "   Force renewal: sudo ./scripts/SSL/zero-downtime-renewal.sh"
echo "   Smart renewal: sudo ./scripts/SSL/smart-renewal.sh"
echo ""
echo "📋 To view SSL monitoring logs:"
echo "   tail -f $CRON_LOG"
echo ""
echo "📋 To manage SSL cron jobs:"
echo "   crontab -l | grep 'SSL certificate monitoring'"
echo ""
echo "🎯 The smart-renewal.sh script will:"
echo "   - Only renew certificates when they expire within 2 days"
echo "   - Use zero-downtime renewal to avoid service interruption"
echo "   - Create backups before renewal and restore if needed"
echo "   - Handle certificate corruption and missing certificates"
echo "   - Provide comprehensive logging for troubleshooting"
