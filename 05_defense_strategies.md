# Defense Strategies Against /etc/passwd Attacks

## 1. Preventive Controls

### File Permissions Hardening
```bash
# Set correct permissions
chmod 644 /etc/passwd
chmod 640 /etc/shadow
chmod 600 /etc/sudoers

# Set immutable flag (Linux)
chattr +i /etc/passwd /etc/shadow
