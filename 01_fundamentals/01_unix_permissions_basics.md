# Unix/Linux File Permissions Fundamentals

## Understanding Permission Notation
Linux uses symbolic notation for permissions: `-rwxrw-r-- 1 user group size date filename`
- First character: File type (`-` = file, `d` = directory)
- Next 9 characters: Permissions in 3 groups (owner/group/others)

## Permission Components
### File Types
- `-` Regular file
- `d` Directory
- `l` Symbolic link
- `c` Character device
- `b` Block device

### Permission Groups
1. **Owner** (first 3 chars)
2. **Group** (middle 3 chars)
3. **Others** (last 3 chars)

### Permission Types
- `r` Read (4)
- `w` Write (2)
- `x` Execute (1)
- `-` No permission

## Octal Notation
| Symbolic | Octal | Meaning |
|----------|-------|---------|
| `rwxrwxrwx` | 777 | All permissions for everyone |
| `rwxr-xr-x` | 755 | Owner: rwx, Others: r-x |
| `rw-r--r--` | 644 | Owner: rw-, Others: r-- |
| `rw-------` | 600 | Owner only |

## Critical System Files
### /etc/passwd
- **Purpose**: User account information
- **Proper permissions**: `-rw-r--r--` (644)
- **Owner**: `root:root`
- **Vulnerable if**: World-writable (`-rw-rw-rw-`)

### /etc/shadow
- **Purpose**: Password hashes
- **Proper permissions**: `-rw-r-----` (640)
- **Owner**: `root:shadow`

### /etc/sudoers
- **Purpose**: Sudo configuration
- **Proper permissions**: `-r--r-----` (440)
- **Owner**: `root:root`

## Checking Permissions
```bash
# Basic view
ls -l /etc/passwd

# Numeric permissions
stat -c "%a %n" /etc/passwd

# Check writable
[ -w /etc/passwd ] && echo "WARNING: File is writable"

# Change permissions
chmod 644 /etc/passwd

# Change ownership
chown root:root /etc/passwd

# Set sticky bit
chmod +t /shared_directory

