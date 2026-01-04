# 🔧 Cách gửi Telegram notification mỗi khi có SSH login

## ✨ 1) Tạo bot Telegram

1. Mở Telegram → tìm **@BotFather**.
    
2. Gửi `/newbot`, đặt tên cho bot, bạn sẽ nhận được **BOT_TOKEN**.
    
3. Gửi tin nhắn bất kỳ tới bot để khởi tạo session.
    
4. Lấy **CHAT_ID** bằng API (ví dụ dùng `getUpdates`):
    
    `https://api.telegram.org/bot<BOT_TOKEN>/getUpdates`
    
    → bạn sẽ thấy `chat->id` chính là Chat ID bot gửi tin đến.
    

---

## 📜 2) Viết script gửi tin nhắn Telegram

Tạo file /etc/pam_scripts/login-notify.sh:

```zsh
#!/usr/bin/env bash
# ============================================
# TELEGRAM SSH LOGIN NOTIFICATION SCRIPT v3.0
# Only for successful logins (PAM open_session)
# ============================================

### CONFIGURATION ###
readonly BOT_TOKEN="6073261344:AAEWZ83zFaVYEXW_vAQB0jLiNyl2pmV-E5k"           # Telegram bot token
readonly CHAT_ID="-5000713182"               # Telegram chat ID
readonly IPINFO_TOKEN=""                      # ipinfo.io token (optional)
readonly TIMEZONE="Asia/Ho_Chi_Minh"
readonly LOG_FILE="/var/log/ssh_notify.log"   # Log file path

# Default whitelist
readonly DEFAULT_WHITELIST=(
    "127.0.0.1"
    "::1"
    "10.30.30.42"
    "10.30.30.44"
    "10.30.30.46"
    "10.20.20.42"
    "10.20.20.44"
    "10.20.20.46"
    "10.110.200.42"
    "10.110.200.44"
    "10.110.200.46"
)

# Whitelist file
readonly WHITELIST_FILE="/etc/ssh/ssh_notify.allow"

# Telegram API
readonly TELEGRAM_API="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"
readonly CURL_OPTS="--connect-timeout 5 --max-time 10 --retry 2"

### END CONFIGURATION ###

# Colors for logging
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    case "$level" in
        "INFO") color="$BLUE" ;;
        "SUCCESS") color="$GREEN" ;;
        "WARN") color="$YELLOW" ;;
        "ERROR") color="$RED" ;;
        *) color="$NC" ;;
    esac
    
    echo -e "${color}[${timestamp}] [${level}] ${message}${NC}" >&2
    
    # Log to file
    if [[ -n "$LOG_FILE" ]]; then
        echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE" 2>/dev/null || true
    fi
}

# Exit if not open_session
if [[ "${PAM_TYPE:-}" != "open_session" ]]; then
    exit 0
fi

# Main variables
USER="${PAM_USER:-unknown}"
CLIENT_IP="${PAM_RHOST:-}"
SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "Unknown")
SERVER_NAME=$(hostname -s 2>/dev/null || echo "unknown")
TIMESTAMP=$(TZ="$TIMEZONE" date "+%Y-%m-%d %H:%M:%S")
DAY_OF_WEEK=$(TZ="$TIMEZONE" date "+%A")

# Get OS info
if command -v lsb_release &>/dev/null; then
    SERVER_OS=$(lsb_release -ds 2>/dev/null)
elif [[ -f /etc/os-release ]]; then
    SERVER_OS=$(source /etc/os-release && echo "$PRETTY_NAME")
else
    SERVER_OS=$(uname -srm)
fi

# Load whitelist
load_whitelist() {
    local whitelist=("${DEFAULT_WHITELIST[@]}")
    
    if [[ -r "$WHITELIST_FILE" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            [[ -z "$line" ]] && continue
            [[ "$line" =~ ^# ]] && continue
            whitelist+=("$line")
        done < "$WHITELIST_FILE"
    fi
    
    echo "${whitelist[@]}"
}

# Check if IP is in CIDR
ip_in_cidr() {
    local ip="$1"
    local cidr="$2"
    
    # Try ipcalc first
    if command -v ipcalc &>/dev/null; then
        if ipcalc -c "$ip" 2>/dev/null | grep -q "IN_NETWORK=1"; then
            return 0
        fi
        return 1
    fi
    
    # Fallback to Python
    if python3 -c "
import ipaddress, sys
try:
    ip = ipaddress.ip_address('$ip')
    net = ipaddress.ip_network('$cidr', strict=False)
    sys.exit(0 if ip in net else 1)
except:
    sys.exit(1)
" 2>/dev/null; then
        return 0
    fi
    
    return 1
}

# Check if IP is whitelisted
is_whitelisted() {
    local ip="$1"
    shift
    local whitelist=("$@")
    
    [[ -z "$ip" ]] && return 0
    [[ "$ip" == "127.0.0.1" ]] || [[ "$ip" == "::1" ]] && return 0
    
    for entry in "${whitelist[@]}"; do
        if [[ "$entry" == */* ]]; then
            ip_in_cidr "$ip" "$entry" && return 0
        else
            [[ "$ip" == "$entry" ]] && return 0
        fi
    done
    
    return 1
}

# Get geolocation
get_geolocation() {
    local ip="$1"
    
    if [[ -z "$ip" ]]; then
        echo "🌐 Local connection"
        return
    fi
    
    # Try ipinfo.io first
    if [[ -n "$IPINFO_TOKEN" ]]; then
        local response
        response=$(curl -s --max-time 5 "https://ipinfo.io/${ip}?token=${IPINFO_TOKEN}" 2>/dev/null || true)
        
        if [[ -n "$response" ]]; then
            local city country region org
            city=$(echo "$response" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
            country=$(echo "$response" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
            region=$(echo "$response" | grep -o '"region":"[^"]*"' | cut -d'"' -f4)
            org=$(echo "$response" | grep -o '"org":"[^"]*"' | cut -d'"' -f4)
            
            if [[ -n "$city" ]]; then
                echo -e "📍 ${city}, ${region}, ${country}\n🏢 ISP: ${org:-Unknown}"
                return
            fi
        fi
    fi
    
    # Fallback to ip-api.com
    local response
    response=$(curl -s --max-time 5 "http://ip-api.com/json/${ip}?fields=status,country,regionName,city,isp" 2>/dev/null || true)
    
    if echo "$response" | grep -q '"status":"success"'; then
        local city country region isp
        city=$(echo "$response" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
        country=$(echo "$response" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
        region=$(echo "$response" | grep -o '"regionName":"[^"]*"' | cut -d'"' -f4)
        isp=$(echo "$response" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
        
        if [[ -n "$city" ]]; then
            echo -e "📍 ${city}, ${region}, ${country}\n🏢 ISP: ${isp:-Unknown}"
            return
        fi
    fi
    
    echo "🌐 Location data unavailable"
}

# Main function
main() {
    log "INFO" "SSH login detected - User: $USER, IP: ${CLIENT_IP:-Local}"
    
    # Check whitelist
    read -ra whitelist <<< "$(load_whitelist)"
    if is_whitelisted "$CLIENT_IP" "${whitelist[@]}"; then
        log "INFO" "IP $CLIENT_IP is whitelisted, skipping notification"
        exit 0
    fi
    
    # Get location info
    local location_info
    location_info=$(get_geolocation "$CLIENT_IP")
    
    # Root warning
    local root_warning=""
    if [[ "$USER" == "root" ]]; then
        root_warning=$'\n⚠️ <b>WARNING: ROOT USER LOGIN DETECTED!</b>'
    fi
    
    # Build message
    local message
    message=$(cat <<EOF
<b>🚀 SSH Login Detected</b>
━━━━━━━━━━━━━━━━━━━━${root_warning}
<b>👤 User:</b> <code>${USER}</code>
<b>🖥️ Server:</b> <code> ${SERVER_NAME} </code> | Server IP: <code>${SERVER_IP}</code>
<b>📱 OS:</b> ${SERVER_OS}
<b>🌐 Client IP:</b> <code>${CLIENT_IP}</code>
${location_info}

<b>📅 Date:</b> ${DAY_OF_WEEK}, ${TIMESTAMP}

━━━━━━━━━━━━━━━━━━━━
<i>#ServerMonitor #SSH #Security</i>
EOF
)
    
    # Send to Telegram
    if curl $CURL_OPTS -X POST "$TELEGRAM_API" \
        -d "chat_id=${CHAT_ID}" \
        -d "parse_mode=HTML" \
        --data-urlencode "text=${message}" >/dev/null 2>&1; then
        log "SUCCESS" "Telegram notification sent"
    else
        log "ERROR" "Failed to send Telegram notification"
    fi
}

# Run main
main
```

➡️ _Thay `YOUR_BOT_TOKEN` và `YOUR_CHAT_ID` bằng thông tin bot của bạn._

✅ Làm cho script executable:

```zsh
sudo chmod +x /etc/pam_scripts/login-notify.sh
```

📌 Bạn cũng có thể thêm các dữ liệu mở rộng (ví dụ hostname server, user, or geolocation lookup), nhưng phần trên là đủ để gửi message cơ bản. [Gist](https://gist.github.com/mmichaelb/3e1d5c365b7bb99b977faf78e7c593bc?utm_source=chatgpt.com)

---

## 🧠 3) Kết nối script với SSH thông qua PAM

Mở file cấu hình SSH PAM:

```zsh
sudo nano /etc/pam.d/sshd
```

Thêm dòng này **cuối file**:

```zsh
# Telegram SSH Login Notification
session optional pam_exec.so seteuid /etc/pam_scripts/login-notify.sh
```

👉 Dòng `pam_exec.so` sẽ gọi script mỗi lần một session SSH mở — tức là khi user login thành công. [Hamalaon](https://hamalaon.com/receive-ssh-login-notifications-in-telegram/?utm_source=chatgpt.com)

---

## 🔁 4) Reload SSH để áp dụng

```zsh
sudo systemctl restart sshd
```

hoặc trên Ubuntu:

```zsh
sudo systemctl restart ssh
```

---

## 🟢 5) Kiểm tra hoạt động

Từ một máy khác:

```zsh
ssh youruser@yourserver
```

→ bạn sẽ nhận được tin nhắn Telegram tương tự:

`[2025-10-10 07:00:01] phitt just logged into ceph01 from 10.10.10.10`

bao gồm:  
✔ Username  
✔ Hostname server  
✔ IP client  
✔ Timestamp chính xác

---

# 💡 Tùy chọn nâng cao

### 📍 Thêm lookup vị trí IP

Bạn có thể lấy thông tin vị trí (city/country) từ IP trước khi gửi tin, bằng ipinfo.io hoặc các API khác để enrich message. [Gist](https://gist.github.com/matriphe/9a51169508f266d97313?utm_source=chatgpt.com)

### 📍 Nhóm nhận thông báo

Nếu gửi vào một **Telegram Group**, chỉ cần thêm bot vào nhóm… và dùng group chat_id để gửi.

### 📍 Lọc chỉ SSH không phải local

Script hiện tại gửi cho mọi SSH login; bạn có thể thêm điều kiện nếu muốn chỉ báo ngoại mạng (`if $IP not local ...`).

---

## ⚠️ Lưu ý

🔐 Script này chạy **trong PAM**, nên phải đảm bảo:  
✔ Script hoạt động nhanh (để không delay login).  
✔ Không ghi log riêng nếu không cần.

📌 Nếu bot gửi nhiều tin quá nhanh (nhiều máy login cùng lúc), bạn có thể debounce hoặc gộp tin nhắn theo giờ.

---

Nếu bạn muốn mình **tự viết script hoàn chỉnh** theo chuẩn bạn muốn (ví dụ định dạng tin nhắn, geolocation, kèm tên host, kèm địa chỉ IP và timezone), mình có thể tạo luôn mẫu cho bạn!