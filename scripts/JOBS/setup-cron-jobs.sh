#!/bin/bash

# HAWA API Cron Jobs Setup Script
# Clean implementation with updated schedules and validation logic

set -e

echo "⏰ HAWA API Cron Jobs Setup"
echo "==========================="

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
CRON_LOG="$LOG_DIR/cron.log"

# Updated Cron Job Schedules
CERT_MANAGEMENT_SCHEDULE="0 0 * * *"    # Daily at midnight (00:00)
LOG_CLEANUP_SCHEDULE="0 3 * * 0"        # Every 2 weeks on Sunday at 3:00 AM
HEALTH_CHECK_SCHEDULE="*/10 * * * *"    # Every 10 minutes
SYSTEM_MONITORING_SCHEDULE="0 4 * * *"  # Daily at 4:00 AM

# Certificate renewal threshold (days before expiry)
RENEWAL_THRESHOLD_DAYS=2

echo "📋 Configuration:"
echo "   Project Directory: $PROJECT_DIR"
echo "   Script Directory: $SCRIPT_DIR"
echo "   Log Directory: $LOG_DIR"
echo "   Cron Log: $CRON_LOG"
echo "   Renewal Threshold: $RENEWAL_THRESHOLD_DAYS days before expiry"
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

# Function to remove existing HAWA API cron jobs
remove_existing_cron_jobs() {
    echo "🧹 Removing existing HAWA API cron jobs..."
    
    # Create temporary cron file
    local temp_cron=$(mktemp)
    
    # Get current crontab and filter out HAWA API jobs
    crontab -l 2>/dev/null | grep -v "HAWA API" | grep -v "$PROJECT_DIR" > "$temp_cron" || touch "$temp_cron"
    
    # Install filtered crontab
    crontab "$temp_cron"
    
    # Clean up
    rm "$temp_cron"
    
    echo "✅ Existing HAWA API cron jobs removed"
}

# Function to show current cron jobs
show_cron_jobs() {
    echo "📋 Current Cron Jobs:"
    echo "===================="
    crontab -l 2>/dev/null | grep -E "(HAWA API|$PROJECT_DIR)" || echo "No HAWA API cron jobs found"
    echo ""
}


# Function to create log cleanup script
create_log_cleanup_script() {
    local cleanup_script="$SCRIPT_DIR/LOG/cleanup-logs.sh"
    local log_dir="$SCRIPT_DIR/LOG"
    
    echo "🔧 Creating log cleanup script..."
    
    # Create LOG directory if it doesn't exist
    mkdir -p "$log_dir"
    
    cat > "$cleanup_script" << 'EOF'
#!/bin/bash

# HAWA API Log Cleanup Script
# Runs every 2 weeks to clean old logs

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
CRON_LOG="$LOG_DIR/cron.log"

echo "$(date): Starting log cleanup..." >> "$CRON_LOG"

# Clean logs older than 14 days
if [ -d "$LOG_DIR" ]; then
    find "$LOG_DIR" -name "*.log" -mtime +14 -delete 2>/dev/null || true
    echo "$(date): Log cleanup completed - removed logs older than 14 days" >> "$CRON_LOG"
else
    echo "$(date): Log directory not found: $LOG_DIR" >> "$CRON_LOG"
fi

# Clean system logs if accessible
if [ -d "/var/log" ]; then
    find /var/log -name "*hawa*" -mtime +14 -delete 2>/dev/null || true
    echo "$(date): System log cleanup completed" >> "$CRON_LOG"
fi
EOF

    chmod +x "$cleanup_script"
    echo "✅ Log cleanup script created: $cleanup_script"
}

# Main setup
echo "🔧 Setting up HAWA API cron jobs..."

# Remove existing jobs first
remove_existing_cron_jobs

# Create helper scripts
create_log_cleanup_script

# Add comprehensive certificate management (daily at midnight)
add_cron_job \
    "$CERT_MANAGEMENT_SCHEDULE" \
    "cd $PROJECT_DIR && sudo $SCRIPT_DIR/SSL/smart-renewal.sh >> $CRON_LOG 2>&1" \
    "HAWA API - Daily certificate management (validation, corruption detection, renewal, service restart)"

# Add log cleanup (every 2 weeks on Sunday at 3 AM)
add_cron_job \
    "$LOG_CLEANUP_SCHEDULE" \
    "cd $PROJECT_DIR && $SCRIPT_DIR/LOG/cleanup-logs.sh >> $CRON_LOG 2>&1" \
    "HAWA API - Bi-weekly log cleanup (removes logs older than 14 days)"

# Add health check (every 10 minutes)
add_cron_job \
    "$HEALTH_CHECK_SCHEDULE" \
    "cd $PROJECT_DIR && curl -s -k https://localhost:3443/health >/dev/null 2>&1 || echo 'API health check failed at \$(date)' >> $CRON_LOG" \
    "HAWA API - Health check every 10 minutes"

# Add system monitoring (daily at 4 AM)
add_cron_job \
    "$SYSTEM_MONITORING_SCHEDULE" \
    "cd $PROJECT_DIR && echo 'System status at \$(date):' >> $CRON_LOG && df -h >> $CRON_LOG && free -h >> $CRON_LOG" \
    "HAWA API - Daily system monitoring"

echo ""
echo "✅ All cron jobs added successfully!"

# Show current cron jobs
show_cron_jobs

# Create cron job management script
JOBS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat > "$JOBS_DIR/manage-cron-jobs.sh" << 'EOF'
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
        if [ -f "scripts/SSL/smart-renewal.sh" ]; then
            chmod +x scripts/SSL/smart-renewal.sh
            sudo ./scripts/SSL/smart-renewal.sh
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
EOF

chmod +x "$JOBS_DIR/manage-cron-jobs.sh"

echo "🔧 Cron job management script created: $JOBS_DIR/manage-cron-jobs.sh"
echo ""
echo "📋 Available Commands:"
echo "   ./scripts/JOBS/manage-cron-jobs.sh list   - Show current cron jobs"
echo "   ./scripts/JOBS/manage-cron-jobs.sh remove - Remove all cron jobs"
echo "   ./scripts/JOBS/manage-cron-jobs.sh logs   - Show recent logs"
echo "   ./scripts/JOBS/manage-cron-jobs.sh test   - Test cron job execution"
echo "   ./scripts/JOBS/manage-cron-jobs.sh status - Show status summary"
echo ""
echo "📅 Updated Cron Job Schedule:"
echo "   Certificate Management: $CERT_MANAGEMENT_SCHEDULE (daily at midnight, comprehensive certificate handling)"
echo "   Log Cleanup: $LOG_CLEANUP_SCHEDULE (every 2 weeks on Sunday at 3:00 AM)"
echo "   Health Check: $HEALTH_CHECK_SCHEDULE (every 10 minutes)"
echo "   System Monitoring: $SYSTEM_MONITORING_SCHEDULE (daily at 4:00 AM)"
echo ""
echo "📁 Logs will be saved to: $CRON_LOG"
echo ""
echo "⚠️  IMPORTANT: Certificate management requires sudo permissions"
echo "   Make sure to configure passwordless sudo for certbot operations:"
echo "   Add this line to /etc/sudoers (use 'sudo visudo'):"
echo "   your_username ALL=(ALL) NOPASSWD: /usr/bin/certbot, /usr/bin/openssl, /bin/systemctl"
echo ""
echo "🎉 Cron jobs setup complete!"