#!/bin/bash

# HAWA API Cron Jobs Management Script

case "$1" in
    "list")
        echo "📋 Current HAWA API Cron Jobs:"
        echo "=============================="
        crontab -l 2>/dev/null | grep -E "(HAWA API|$(pwd))" || echo "No HAWA API cron jobs found"
        ;;
    "remove")
        echo "🧹 Removing all HAWA API cron jobs..."
        temp_cron=$(mktemp)
        crontab -l 2>/dev/null | grep -v "HAWA API" | grep -v "$(pwd)" > "$temp_cron" || touch "$temp_cron"
        crontab "$temp_cron"
        rm "$temp_cron"
        echo "✅ All HAWA API cron jobs removed"
        ;;
    "logs")
        echo "📋 Recent cron job logs:"
        echo "========================"
        if [ -f "logs/cron.log" ]; then
            tail -50 logs/cron.log
        else
            echo "No cron logs found"
        fi
        echo ""
        echo "📋 Recent certificate management logs:"
        echo "====================================="
        if [ -f "logs/certificate-manager.log" ]; then
            tail -50 logs/certificate-manager.log
        else
            echo "No certificate management logs found"
        fi
        ;;
    "test")
        echo "🧪 Testing cron job execution..."
        echo "Running certificate management test..."
        if [ -f "scripts/JOBS/certificate-manager.sh" ]; then
            chmod +x scripts/JOBS/certificate-manager.sh
            ./scripts/JOBS/certificate-manager.sh
        else
            echo "❌ Certificate management script not found"
        fi
        echo "Running health check..."
        curl -s -k https://localhost:3443/health && echo "✅ Health check passed" || echo "❌ Health check failed"
        ;;
    "status")
        echo "📊 HAWA API Cron Jobs Status:"
        echo "============================="
        echo "Certificate Management: $(crontab -l 2>/dev/null | grep 'certificate management' | wc -l) job(s)"
        echo "Log Cleanup: $(crontab -l 2>/dev/null | grep 'log cleanup' | wc -l) job(s)"
        echo "Health Check: $(crontab -l 2>/dev/null | grep 'Health check' | wc -l) job(s)"
        echo "System Monitoring: $(crontab -l 2>/dev/null | grep 'system monitoring' | wc -l) job(s)"
        ;;
    *)
        echo "HAWA API Cron Jobs Management"
        echo "============================="
        echo "Usage: $0 {list|remove|logs|test|status}"
        echo ""
        echo "Commands:"
        echo "  list   - Show current cron jobs"
        echo "  remove - Remove all HAWA API cron jobs"
        echo "  logs   - Show recent cron job logs"
        echo "  test   - Test cron job execution"
        echo "  status - Show cron jobs status summary"
        ;;
esac
