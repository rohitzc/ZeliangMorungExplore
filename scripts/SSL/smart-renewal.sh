#!/bin/bash

# HAWA API Smart Certificate Renewal Script
# Only renews if certificate expires within threshold days

set -e

# Configuration
DOMAIN="api.npcb.in"
CERT_FILE="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
RENEWAL_THRESHOLD_DAYS=2
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_FILE="$PROJECT_DIR/logs/cron.log"

# Function to get certificate expiry date
get_cert_expiry() {
    if sudo openssl x509 -dates -noout -in "$CERT_FILE" 2>/dev/null | grep "notAfter" | cut -d= -f2; then
        return 0
    else
        return 1
    fi
}

# Function to calculate days until expiry
days_until_expiry() {
    local expiry_date="$1"
    local expiry_timestamp=$(date -d "$expiry_date" +%s 2>/dev/null || echo "0")
    local current_timestamp=$(date +%s)
    local days_until=$(( (expiry_timestamp - current_timestamp) / 86400 ))
    echo "$days_until"
}

# Main renewal logic
echo "$(date): Starting smart certificate renewal check..." >> "$LOG_FILE"

# Check if certificate exists and is valid
if ! sudo openssl x509 -dates -noout -in "$CERT_FILE" 2>/dev/null; then
    echo "$(date): Certificate not found or invalid, attempting renewal..." >> "$LOG_FILE"
    cd "$PROJECT_DIR"
    ./scripts/SSL/zero-downtime-renewal.sh >> "$LOG_FILE" 2>&1
    exit 0
fi

# Get expiry date and calculate days until expiry
expiry_date=$(get_cert_expiry)
if [ -z "$expiry_date" ]; then
    echo "$(date): Could not determine certificate expiry date" >> "$LOG_FILE"
    exit 1
fi

days_until=$(days_until_expiry "$expiry_date")

echo "$(date): Certificate expires in $days_until days (expiry: $expiry_date)" >> "$LOG_FILE"

# Only renew if within threshold
if [ "$days_until" -le "$RENEWAL_THRESHOLD_DAYS" ]; then
    echo "$(date): Certificate expires within $RENEWAL_THRESHOLD_DAYS days, initiating renewal..." >> "$LOG_FILE"
    cd "$PROJECT_DIR"
    ./scripts/SSL/zero-downtime-renewal.sh >> "$LOG_FILE" 2>&1
    echo "$(date): Certificate renewal completed" >> "$LOG_FILE"
else
    echo "$(date): Certificate is valid for $days_until days, no renewal needed" >> "$LOG_FILE"
fi
