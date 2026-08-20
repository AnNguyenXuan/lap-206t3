#!/usr/bin/env bash
# Rocky Linux 9 security hardening script

set -Eeuo pipefail

# -----------------------------
# Tunable policy values
# -----------------------------
TMOUT_SECONDS="${TMOUT_SECONDS:-300}"
PASSWORD_MIN_LENGTH="${PASSWORD_MIN_LENGTH:-8}"
FAILLOCK_DENY="${FAILLOCK_DENY:-5}"
FAILLOCK_UNLOCK_TIME="${FAILLOCK_UNLOCK_TIME:-300}"
PASSWORD_HISTORY="${PASSWORD_HISTORY:-5}"
PASS_MAX_DAYS="${PASS_MAX_DAYS:-90}"
PASS_MIN_DAYS="${PASS_MIN_DAYS:-1}"
SSH_ALLOW_USERS="${SSH_ALLOW_USERS:-}"
CONFIGURE_RPFILTER="${CONFIGURE_RPFILTER:-1}"

# Ciphers requested by the assessment after removing its disallowed cipher set.
SSH_CIPHERS="${SSH_CIPHERS:-aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr}"
SSH_MACS="${SSH_MACS:-hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256}"

STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="/root/rocky9-hardening-backup-${STAMP}"
LOG_FILE="/var/log/rocky9-security-hardening.log"

log()  { printf '[%s] %s\n' "$(date '+%F %T')" "$*"; }
warn() { printf '[%s] WARNING: %s\n' "$(date '+%F %T')" "$*" >&2; }
die()  { printf '[%s] ERROR: %s\n' "$(date '+%F %T')" "$*" >&2; exit 1; }

[[ ${EUID} -eq 0 ]] || die "Run this script as root."

mkdir -p "$BACKUP_DIR" "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
chmod 0600 "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

log "Starting Rocky Linux 9 hardening."
log "Backup directory: $BACKUP_DIR"

# -----------------------------
# OS sanity check
# -----------------------------
if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    if [[ "${VERSION_ID%%.*}" != "9" ]]; then
        die "This script is intended for Rocky/RHEL-compatible major version 9; detected VERSION_ID=${VERSION_ID:-unknown}."
    fi
    log "Detected OS: ${PRETTY_NAME:-unknown}"
else
    die "/etc/os-release not found."
fi

# -----------------------------
# Generic helpers
# -----------------------------
backup_path() {
    local p="$1"
    if [[ -e "$p" || -L "$p" ]]; then
        mkdir -p "$BACKUP_DIR$(dirname "$p")"
        cp -a "$p" "$BACKUP_DIR$p"
    fi
}

set_eq_key() {
    # Set a key in files that use: key = value (or commented equivalent)
    local file="$1" key="$2" value="$3"
    touch "$file"
    if grep -Eq "^[[:space:]#]*${key}[[:space:]]*=" "$file"; then
        sed -ri "s|^[[:space:]#]*${key}[[:space:]]*=.*$|${key} = ${value}|" "$file"
    else
        printf '%s = %s\n' "$key" "$value" >> "$file"
    fi
}

set_space_key() {
    # Set a key in files that use: KEY value (or commented equivalent)
    local file="$1" key="$2" value="$3"
    touch "$file"
    if grep -Eq "^[[:space:]#]*${key}[[:space:]]+" "$file"; then
        sed -ri "s|^[[:space:]#]*${key}[[:space:]]+.*$|${key} ${value}|" "$file"
    else
        printf '%s %s\n' "$key" "$value" >> "$file"
    fi
}

ensure_flag_line() {
    local file="$1" flag="$2"
    touch "$file"
    if grep -Eq "^[[:space:]]*${flag}([[:space:]]*(#.*)?)?$" "$file"; then
        sed -ri "s|^[[:space:]]*${flag}.*$|${flag}|" "$file"
    elif grep -Eq "^[[:space:]]*#[[:space:]]*${flag}([[:space:]]*(#.*)?)?$" "$file"; then
        sed -ri "s|^[[:space:]]*#[[:space:]]*${flag}.*$|${flag}|" "$file"
    else
        printf '%s\n' "$flag" >> "$file"
    fi
}

# -----------------------------
# 1) rsyslog default file mode = 0640
# -----------------------------
log "Configuring rsyslog default file creation mode."
RSYSLOG_HARDEN="/etc/rsyslog.d/00-security-file-mode.conf"
backup_path "$RSYSLOG_HARDEN"
mkdir -p /etc/rsyslog.d
cat > "$RSYSLOG_HARDEN" <<'EOC'
# Security hardening: files newly created by rsyslog are not world-readable.
$FileCreateMode 0640
EOC
chmod 0644 "$RSYSLOG_HARDEN"
chown root:root "$RSYSLOG_HARDEN"
if systemctl is-active --quiet rsyslog 2>/dev/null; then
    systemctl restart rsyslog
else
    warn "rsyslog service is not active; configuration was written but service was not restarted."
fi

# -----------------------------
# 2) logrotate: weekly + 13 rotations (>= ~90 days)
# -----------------------------
log "Configuring global logrotate retention to weekly / rotate 13."
LOGROTATE_CONF="/etc/logrotate.conf"
if [[ -f "$LOGROTATE_CONF" ]]; then
    backup_path "$LOGROTATE_CONF"
    tmp="$(mktemp)"
    awk '
        BEGIN {
            print "# Security retention baseline"
            print "weekly"
            print "rotate 13"
            depth=0
        }
        {
            line=$0
            # Only replace/remove global directives outside log stanzas.
            if (depth == 0 && line ~ /^[[:space:]]*(daily|weekly|monthly|yearly)[[:space:]]*([#].*)?$/) next
            if (depth == 0 && line ~ /^[[:space:]]*rotate[[:space:]]+[0-9]+/) next
            if (depth == 0 && line ~ /^[[:space:]]*(maxage|maxsize)[[:space:]]+/) next
            print line
            opens=gsub(/\{/, "{", line)
            closes=gsub(/\}/, "}", line)
            depth += opens - closes
            if (depth < 0) depth=0
        }
    ' "$LOGROTATE_CONF" > "$tmp"
    cat "$tmp" > "$LOGROTATE_CONF"
    rm -f "$tmp"
    chmod 0644 "$LOGROTATE_CONF"
    chown root:root "$LOGROTATE_CONF"

    if command -v logrotate >/dev/null 2>&1; then
        if ! logrotate -d "$LOGROTATE_CONF" >/tmp/rocky9-logrotate-check.$$ 2>&1; then
            warn "logrotate validation reported an error. Review /tmp/rocky9-logrotate-check.$$ before production use."
        else
            rm -f /tmp/rocky9-logrotate-check.$$
        fi
    fi

    # Per-service files can override the global retention policy. Report them rather than
    # blindly rewriting application-specific rotation logic.
    if grep -REn '^[[:space:]]*(rotate[[:space:]]+[0-9]+|maxage[[:space:]]+|maxsize[[:space:]]+)' /etc/logrotate.d 2>/dev/null; then
        warn "One or more /etc/logrotate.d/* files override retention/size. Review the lines above if the assessment requires every log to retain >=90 days."
    fi
else
    warn "$LOGROTATE_CONF not found; skipped logrotate configuration."
fi

# -----------------------------
# 3) sudo use_pty + dedicated sudo log
# -----------------------------
log "Configuring sudo use_pty and command logging."
SUDO_HARDEN="/etc/sudoers.d/99-security-hardening"
backup_path "$SUDO_HARDEN"
mkdir -p /etc/sudoers.d
cat > "$SUDO_HARDEN" <<'EOC'
Defaults use_pty
Defaults logfile="/var/log/sudo.log"
EOC
chmod 0440 "$SUDO_HARDEN"
chown root:root "$SUDO_HARDEN"
touch /var/log/sudo.log
chmod 0600 /var/log/sudo.log
chown root:root /var/log/sudo.log
if command -v restorecon >/dev/null 2>&1; then restorecon -F /var/log/sudo.log "$SUDO_HARDEN" >/dev/null 2>&1 || true; fi
if command -v visudo >/dev/null 2>&1; then
    visudo -cf /etc/sudoers >/dev/null || die "sudoers validation failed. Restore from $BACKUP_DIR before ending the administrative session."
else
    warn "visudo not found; sudoers syntax was not validated."
fi

# -----------------------------
# 4) Shell inactivity timeout
# -----------------------------
log "Configuring shell TMOUT=${TMOUT_SECONDS}."
TMOUT_FILE="/etc/profile.d/99-security-tmout.sh"
backup_path "$TMOUT_FILE"
cat > "$TMOUT_FILE" <<EOC
# Security hardening: auto-logout inactive interactive shells.
TMOUT=${TMOUT_SECONDS}
readonly TMOUT
export TMOUT
EOC
chmod 0644 "$TMOUT_FILE"
chown root:root "$TMOUT_FILE"

# -----------------------------
# 5) SSH server hardening
# -----------------------------
log "Configuring SSH server hardening."
SSH_HARDEN="/etc/ssh/sshd_config.d/49-security-hardening.conf"
backup_path "$SSH_HARDEN"
mkdir -p /etc/ssh/sshd_config.d
{
    echo '# Security hardening'
    echo 'PermitRootLogin no'
    echo 'AllowTcpForwarding no'
    echo "Ciphers ${SSH_CIPHERS}"
    echo "MACs ${SSH_MACS}"
    if [[ -n "${SSH_ALLOW_USERS// }" ]]; then
        echo "AllowUsers ${SSH_ALLOW_USERS}"
    fi
} > "$SSH_HARDEN"
chmod 0600 "$SSH_HARDEN"
chown root:root "$SSH_HARDEN"

if [[ -z "${SSH_ALLOW_USERS// }" ]]; then
    warn "SSH AllowUsers was NOT set because the authorized account list is not present in the workbook. Re-run with SSH_ALLOW_USERS=\"user1 user2\" to enforce it safely."
fi

if command -v sshd >/dev/null 2>&1; then
    if ! sshd -t; then
        if [[ -f "$BACKUP_DIR$SSH_HARDEN" ]]; then
            cp -a "$BACKUP_DIR$SSH_HARDEN" "$SSH_HARDEN"
        else
            rm -f "$SSH_HARDEN"
        fi
        die "sshd validation failed; SSH hardening file was rolled back."
    fi
    if systemctl is-active --quiet sshd 2>/dev/null; then
        systemctl reload sshd
    else
        warn "sshd service is not active; configuration was validated but not reloaded."
    fi
else
    warn "sshd command not found; SSH configuration was written but not validated/reloaded."
fi

# -----------------------------
# 6) Password quality, lockout, and password history
# -----------------------------
log "Configuring password/PAM policy."
PWQUALITY_CONF="/etc/security/pwquality.conf"
FAILLOCK_CONF="/etc/security/faillock.conf"
PWHISTORY_CONF="/etc/security/pwhistory.conf"
for f in "$PWQUALITY_CONF" "$FAILLOCK_CONF" "$PWHISTORY_CONF"; do backup_path "$f"; done
backup_path /etc/authselect
backup_path /etc/pam.d/system-auth
backup_path /etc/pam.d/password-auth

mkdir -p /etc/security
set_eq_key "$PWQUALITY_CONF" minlen "$PASSWORD_MIN_LENGTH"
ensure_flag_line "$PWQUALITY_CONF" enforce_for_root
set_eq_key "$FAILLOCK_CONF" deny "$FAILLOCK_DENY"
set_eq_key "$FAILLOCK_CONF" unlock_time "$FAILLOCK_UNLOCK_TIME"
set_eq_key "$PWHISTORY_CONF" remember "$PASSWORD_HISTORY"

# On Rocky/RHEL 9, PAM stacks are normally managed by authselect. Enable tested
# profile features instead of editing generated system-auth/password-auth directly.
if command -v authselect >/dev/null 2>&1 && authselect current >/dev/null 2>&1; then
    current_authselect="$(authselect current 2>&1 || true)"
    log "Current authselect profile before changes:"
    printf '%s\n' "$current_authselect"

    if ! grep -q 'with-faillock' <<<"$current_authselect"; then
        if ! authselect enable-feature with-faillock; then
            warn "Could not enable authselect feature with-faillock. Check the current/custom authselect profile manually."
        fi
    fi
    current_authselect="$(authselect current 2>&1 || true)"
    if ! grep -q 'with-pwhistory' <<<"$current_authselect"; then
        if ! authselect enable-feature with-pwhistory; then
            warn "Could not enable authselect feature with-pwhistory. Check the current/custom authselect profile manually."
        fi
    fi
    authselect apply-changes || warn "authselect apply-changes returned an error. Review PAM configuration before closing the current session."
    authselect check || warn "authselect check reported an issue. Review PAM configuration before closing the current session."
else
    warn "No active authselect profile detected. Policy files were configured, but this script did not directly rewrite generated PAM stacks. Confirm pam_pwquality, pam_faillock and pam_pwhistory are present in the active PAM stack."
fi

# -----------------------------
# 7) Password aging
# -----------------------------
log "Configuring password aging defaults."
LOGIN_DEFS="/etc/login.defs"
backup_path "$LOGIN_DEFS"
set_space_key "$LOGIN_DEFS" PASS_MAX_DAYS "$PASS_MAX_DAYS"
set_space_key "$LOGIN_DEFS" PASS_MIN_DAYS "$PASS_MIN_DAYS"

# Apply the exact existing-account exceptions identified by the workbook when present.
if grep -q '^vtidc_vdi:' /etc/passwd; then
    chage -M "$PASS_MAX_DAYS" vtidc_vdi
    log "Applied PASS_MAX_DAYS=${PASS_MAX_DAYS} to local user vtidc_vdi."
elif getent passwd vtidc_vdi >/dev/null 2>&1; then
    warn "vtidc_vdi is not a local /etc/passwd account; password aging must be enforced by its identity provider."
fi
for u in vtidc_vdi ducdm1 quangld5 annx; do
    if grep -q "^${u}:" /etc/passwd; then
        chage -m "$PASS_MIN_DAYS" "$u"
        log "Applied PASS_MIN_DAYS=${PASS_MIN_DAYS} to local user $u."
    elif getent passwd "$u" >/dev/null 2>&1; then
        warn "$u is not a local /etc/passwd account; minimum password age must be enforced by its identity provider."
    fi
done

# -----------------------------
# 8) Cron file and directory permissions
# -----------------------------
log "Hardening cron permissions."
for f in /etc/crontab /etc/cron.deny /etc/cron.allow; do
    if [[ -e "$f" ]]; then
        backup_path "$f"
        chown root:root "$f"
        chmod 0600 "$f"
    fi
done

for d in /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly /etc/cron.d; do
    if [[ -d "$d" ]]; then
        backup_path "$d"
        chown root:root "$d"
        chmod 0700 "$d"
    fi
done

# -----------------------------
# 9) IPv4 sysctl hardening
# -----------------------------
log "Configuring IPv4 redirect/martian packet controls."
SYSCTL_HARDEN="/etc/sysctl.d/99-security-hardening.conf"
backup_path "$SYSCTL_HARDEN"
{
    echo '# Security hardening'
    echo 'net.ipv4.conf.all.send_redirects = 0'
    echo 'net.ipv4.conf.default.send_redirects = 0'
    echo 'net.ipv4.conf.all.accept_redirects = 0'
    echo 'net.ipv4.conf.default.accept_redirects = 0'
    echo 'net.ipv4.conf.all.secure_redirects = 0'
    echo 'net.ipv4.conf.default.secure_redirects = 0'
    echo 'net.ipv4.conf.all.log_martians = 1'
    echo 'net.ipv4.conf.default.log_martians = 1'
    if [[ "$CONFIGURE_RPFILTER" == "1" ]]; then
        echo 'net.ipv4.conf.all.rp_filter = 1'
        echo 'net.ipv4.conf.default.rp_filter = 1'
    fi
} > "$SYSCTL_HARDEN"
chmod 0644 "$SYSCTL_HARDEN"
chown root:root "$SYSCTL_HARDEN"

if [[ "$CONFIGURE_RPFILTER" != "1" ]]; then
    warn "Reverse Path Filtering was intentionally skipped because CONFIGURE_RPFILTER=${CONFIGURE_RPFILTER}."
fi
if ! sysctl -p "$SYSCTL_HARDEN" >/dev/null; then
    warn "One or more hardening sysctl values could not be applied at runtime; the persistent file remains in place."
fi

# -----------------------------
# Verification summary
# -----------------------------
log "----- Verification summary -----"

if command -v sshd >/dev/null 2>&1; then
    log "Effective SSH settings:"
    sshd -T | grep -E '^(permitrootlogin|allowtcpforwarding|allowusers|ciphers|macs)[[:space:]]' || true
fi

log "Password quality:"
grep -E '^[[:space:]]*(minlen[[:space:]]*=|enforce_for_root)' "$PWQUALITY_CONF" || true
log "Account lockout:"
grep -E '^[[:space:]]*(deny|unlock_time)[[:space:]]*=' "$FAILLOCK_CONF" || true
log "Password history:"
grep -E '^[[:space:]]*remember[[:space:]]*=' "$PWHISTORY_CONF" || true
log "Password aging defaults:"
grep -E '^[[:space:]]*PASS_(MAX|MIN)_DAYS[[:space:]]+' "$LOGIN_DEFS" || true
log "Sysctl values:"
sysctl net.ipv4.conf.all.send_redirects \
       net.ipv4.conf.default.send_redirects \
       net.ipv4.conf.all.accept_redirects \
       net.ipv4.conf.default.accept_redirects \
       net.ipv4.conf.all.secure_redirects \
       net.ipv4.conf.default.secure_redirects \
       net.ipv4.conf.all.log_martians \
       net.ipv4.conf.default.log_martians 2>/dev/null || true
if [[ "$CONFIGURE_RPFILTER" == "1" ]]; then
    sysctl net.ipv4.conf.all.rp_filter net.ipv4.conf.default.rp_filter 2>/dev/null || true
fi

log "Hardening completed."
log "Backups: $BACKUP_DIR"
log "Execution log: $LOG_FILE"
log "Review all WARNING lines before closing your current privileged session."
