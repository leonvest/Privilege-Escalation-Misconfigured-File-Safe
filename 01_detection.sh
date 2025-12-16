#!/bin/bash
# Critical File Permission Checker
# Usage: ./detection.sh

echo "=== Critical File Permission Audit ==="
echo "Date: $(date)"
echo "Host: $(hostname)"
echo

CRITICAL_FILES=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/sudoers"
    "/etc/sudoers.d/"
    "/root/.ssh/authorized_keys"
    "/etc/ssh/sshd_config"
)

ALERT=false

for file in "${CRITICAL_FILES[@]}"; do
    if [ -e "$file" ]; then
        if [ -d "$file" ]; then
            # Handle directory
            perms=$(find "$file" -type f -exec stat -c "%a" {} \; 2>/dev/null | sort -u)
            details="Directory - checking contents"
        else
            # Handle file
            perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%p" "$file" | sed 's/.*//')
            details=$(ls -la "$file")
        fi
        
        echo "Checking: $file"
        echo "Permissions: $perms"
        
        # Check for world-writable
        if [[ "$perms" =~ .*[2-7][2-7][2-7].* ]]; then
            echo "⚠️  ALERT: World-writable permissions detected!"
            echo "Details: $details"
            ALERT=true
        fi
        
        echo "---"
    fi
done

if $ALERT; then
    echo "❌ Security issues detected!"
    exit 1
else
    echo "✅ No critical permission issues found"
    exit 0
fi
