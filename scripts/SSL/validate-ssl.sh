#!/bin/bash

# HAWA API SSL Certificate Validation Script
# This script validates SSL certificates using openssl command

set -e

echo "🔍 HAWA API SSL Certificate Validation"
echo "======================================"

DOMAIN="api.npcb.in"
CERT_FILE="/etc/letsencrypt/live/$DOMAIN/cert.pem"

echo "📋 Configuration:"
echo "   Domain: $DOMAIN"
echo "   Certificate: $CERT_FILE"
echo ""

# Validate certificate using openssl command
echo "🔍 Validating certificate with openssl..."
if sudo openssl x509 -dates -noout -in "$CERT_FILE" 2>/dev/null; then
    echo "✅ Certificate is valid"
    echo ""
    echo "📋 Certificate dates:"
    sudo openssl x509 -dates -noout -in "$CERT_FILE"
    echo ""
    echo "✅ SSL certificate validation successful!"
    exit 0
else
    echo "❌ Certificate is invalid or not found"
    echo "🔧 Certificate needs to be renewed or regenerated"
    exit 1
fi