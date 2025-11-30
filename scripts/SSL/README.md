# SSL Scripts Directory

This directory contains the essential SSL certificate management scripts for the HAWA API.

## 📁 Scripts Overview

### 🔧 Main Scripts

#### `ssl-setup.sh` - **Main SSL Manager**
- **Purpose**: Comprehensive SSL certificate management interface
- **Usage**: `npm run setup:ssl` or `./ssl-setup.sh`
- **Features**:
  - Let's Encrypt setup
  - Existing certificate setup
  - Certificate validation
  - Certificate renewal
  - Port 80 conflict handling
  - Interactive menu system

#### `zero-downtime-renewal.sh` - **Zero-Downtime Certificate Renewer**
- **Purpose**: Intelligent certificate renewal with zero downtime
- **Usage**: `sudo ./zero-downtime-renewal.sh`
- **Features**:
  - Daily expiry check
  - 2-day renewal threshold (configurable)
  - Zero-downtime renewal using SIGHUP signals
  - Automatic fallback to restart if needed
  - Certificate backup and restore
  - Health monitoring and verification

#### `validate-ssl.sh` - **Certificate Validator**
- **Purpose**: Validate SSL certificate integrity
- **Usage**: `./validate-ssl.sh`
- **Features**:
  - Certificate validity check
  - Private key validation
  - Certificate-key matching verification
  - Expiry date display
  - Detailed certificate information

#### `setup-letsencrypt.sh` - **Let's Encrypt Setup**
- **Purpose**: Automated Let's Encrypt certificate acquisition
- **Usage**: `sudo ./setup-letsencrypt.sh`
- **Features**:
  - Domain validation
  - Automatic certificate installation
  - Certificate copying to project directory
  - Service restart handling

## 🚀 Quick Start

### 1. Setup SSL (Recommended)
```bash
npm run setup:ssl
```

### 2. Manual Certificate Renewal (Zero-Downtime)
```bash
sudo ./zero-downtime-renewal.sh
```

### 3. Validate Certificates
```bash
./validate-ssl.sh
```

### 4. Let's Encrypt Setup
```bash
sudo ./setup-letsencrypt.sh
```

## ⚙️ Configuration

### SSL Configuration
- **Domain**: `api.npcb.in`
- **Email**: `rohit@zeliangcodetech.com`
- **SSL Directory**: `./ssl`
- **Certificate File**: `./ssl/cert.pem`
- **Private Key**: `./ssl/private.key`
- **Renewal Threshold**: 2 days

### Port 80 Handling
- Automatically detects port 80 conflicts
- Stops Bitnami services: `/opt/bitnami/ctlscript.sh stop`
- Waits for services to stop before proceeding

## 📅 Cron Integration

The `smart-certificate-renewal.sh` script is designed to work with cron jobs:
- **Schedule**: Daily at 2:00 AM
- **Logic**: Only renews when certificate expires in < 2 days
- **Logging**: All operations logged to `./logs/cron.log`

## 🔧 Script Relationships

```
ssl-setup.sh (Main Interface)
├── setup-letsencrypt.sh (Let's Encrypt)
├── validate-ssl.sh (Validation)
└── zero-downtime-renewal.sh (Zero-Downtime Renewal)

Cron Jobs
└── zero-downtime-renewal.sh (Automated)
```

## 📝 Notes

1. **Zero-Downtime Renewal**: Only renews certificates when they expire in less than 2 days
2. **Port 80 Handling**: Automatically stops Bitnami services to free port 80
3. **Zero Downtime**: Uses SIGHUP signals to reload certificates without restarting the API
4. **Automatic Fallback**: Falls back to restart if zero-downtime reload fails
5. **Certificate Backup**: Creates backups before renewal and restores if needed
6. **Comprehensive Logging**: All operations are logged for troubleshooting
7. **Error Handling**: Robust error handling with multiple fallback options

## 🚨 Important

- Always run SSL scripts with appropriate permissions
- Let's Encrypt requires a domain name (not IP address)
- Use proper SSL certificates for production (no self-signed certificates)
- Cron jobs require proper system permissions
- Port 80 conflicts are automatically handled
