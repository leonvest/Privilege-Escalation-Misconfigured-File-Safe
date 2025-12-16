#!/bin/bash
# Fix /etc/passwd permissions and security hardening
# Usage: sudo ./mitigation.sh

set -e

echo "=== Security Hardening Script ==="

# 1. Fix /etc/passwd permissions
echo "[1] Fixing /etc/passwd permissions..."
chmod 644 /etc/passwd
chown root:root /etc/passwd

# 2. Check for suspicious entries
echo "[2] Checking for suspicious /etc/passwd entries..."
suspicious=$(grep -E "^[^:]*::[0-9]*:0:" /etc/passwd || true)
if [ -n "$suspicious" ]; then
    echo " Suspicious entries found:"
    echo "$suspicious"
    echo "Consider removing these entries"
fi

# 3. Set /etc/shadow permissions
echo "[3] Securing /etc/shadow..."
chmod 640 /etc/shadow
chown root:shadow /etc/shadow

# 4. Check other critical files
echo "[4] Securing other critical files..."
files=(
    "/etc/group"
    "/etc/gshadow"
    "/etc/sudoers"
    "/etc/ssh/sshd_config"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        chmod 600 "$file" 2>/dev/null || chmod 640 "$file" 2>/dev/null || true
        chown root:root "$file" 2>/dev/null || true
    fi
done

# 5. Install audit tools
echo "[5] Installing security tools..."
if command -v apt-get &> /dev/null; then
    apt-get update && apt-get install -y aide audispd-plugins
elif command -v yum &> /dev/null; then
    yum install -y aide audit
fi

# 6. Create monitoring script
echo "[6] Setting up file integrity monitoring..."
cat > /usr/local/bin/check-critical-files.sh << 'EOF'
#!/bin/bash
# Critical file permission checker - run via cron

CRITICAL_FILES="/etc/passwd /etc/shadow /etc/sudoers"

for file in $CRITICAL_FILES; do
    if [ -f "$file" ]; then
        perms=$(stat -c "%a" "$file")
        if [[ "$perms" =~ .*[2-7][2-7][2-7].* ]]; then
            echo "ALERT: $file is world-writable (perms: $perms)" | mail -s "Security Alert on $(hostname)" admin@example.com
            logger -p auth.emerg "SECURITY: $file has world-writable permissions"
        fi
    fi
done
EOF

chmod 755 /usr/local/bin/check-critical-files.sh

echo "[+] Mitigation complete!"
echo "[*] Consider adding to crontab:"
echo "    */5 * * * * /usr/local/bin/check-critical-files.sh"
