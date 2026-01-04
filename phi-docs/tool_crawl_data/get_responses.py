import os
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed

# Tạo thư mục output nếu chưa tồn tại
os.makedirs("./responses", exist_ok=True)

# Đọc và xử lý UIDs
with open("hehe.txt", "r") as f:
    uids = [line.strip() for line in f if line.strip()]

# Cấu hình curl cố định
BASE_CURL = [
    "curl",
    "-k",
    "-G",
    "https://admin.hostingviet.vn/",
    "--http2",
    "--compressed",
    "-H", "Host: admin.hostingviet.vn",
    "-H", "Cookie: PHPSESSID=otpv7nlfnf9lfh55v9f1365nkr",
    "-H", "Sec-Ch-Ua: \"Chromium\";v=\"137\", \"Not/A)Brand\";v=\"24\"",
    "-H", "Sec-Ch-Ua-Mobile: ?0",
    "-H", "Sec-Ch-Ua-Platform: \"Linux\"",
    "-H", "Accept-Language: en-US,en;q=0.9",
    "-H", "Upgrade-Insecure-Requests: 1",
    "-H", "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36",
    "-H", "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    "-H", "Sec-Fetch-Site: same-origin",
    "-H", "Sec-Fetch-Mode: navigate",
    "-H", "Sec-Fetch-User: ?1",
    "-H", "Sec-Fetch-Dest: document",
    "-H", "Referer: https://admin.hostingviet.vn/?hdl=index",
    "-H", "Priority: u=0, i",
    "--data-urlencode", "hdl=service/list",
    "--data-urlencode", "search_inactive_service=",
    "--data-urlencode", "start_date_search=",
    "--data-urlencode", "end_date_search=",
    "--data-urlencode", "emp_service_owner=",
    "--data-urlencode", "money_status_detail=",
    "--data-urlencode", "no_search_time=1",
    "--data-urlencode", "frmtoken=8075e2c38ef8cd3fba1fdcb3b448b50a8d97527db4abb0b18e6f1e33e0b69988",
]

def fetch_uid(uid):
    """Xử lý request cho một UID"""
    cmd = BASE_CURL + [
        "--data-urlencode", f"filter[username]={uid}",
        "-o", f"./responses/{uid}.html",
        "--silent",  # Ẩn output tiến trình không cần thiết
        "--fail"     # Trả về lỗi khi HTTP status >= 400
    ]
    
    try:
        result = subprocess.run(
            cmd,
            check=True,
            timeout=100,
            stderr=subprocess.PIPE,
            stdout=subprocess.PIPE
        )
        return (uid, True, None)
    except subprocess.CalledProcessError as e:
        return (uid, False, f"HTTP Error: {e.stderr.decode().strip()}")
    except subprocess.TimeoutExpired:
        return (uid, False, "Timeout after 30s")
    except Exception as e:
        return (uid, False, str(e))

# Xử lý đa luồng
with ThreadPoolExecutor(max_workers=20) as executor:  # Điều chỉnh số luồng tại đây
    futures = {executor.submit(fetch_uid, uid): uid for uid in uids}
    
    success = 0
    total = len(uids)
    
    for future in as_completed(futures):
        uid, status, error = future.result()
        if status:
            success += 1
            print(f"✅ Thành công: {uid}")
        else:
            print(f"❌ Thất bại: {uid} - Lý do: {error}")

print(f"\nTổng kết: {success}/{total} request thành công ({success/total:.1%})")
