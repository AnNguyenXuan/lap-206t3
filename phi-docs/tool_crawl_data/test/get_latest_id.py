import requests
from bs4 import BeautifulSoup
from concurrent.futures import ThreadPoolExecutor, as_completed
from urllib3.exceptions import InsecureRequestWarning
import urllib3

urllib3.disable_warnings(InsecureRequestWarning)
PHPSESSID_VALUE = "otpv7nlfnf9lfh55v9f1365nkr"  # <- Bạn điền PHPSESSID ở đây

def process_link(index, link, session):
    """Xử lý 1 link: lấy mã dịch vụ mới nhất hoặc trả lỗi."""
    try:
        resp = session.get(link, timeout=10, verify=False)
        resp.raise_for_status()
    except Exception as e:
        return index, link, None, f"Lỗi khi truy cập liên kết: {e}"

    try:
        soup = BeautifulSoup(resp.text, 'html.parser')
        row = soup.find('td', string=lambda x: x and 'Mã dịch vụ' in x)
        if not row:
            raise ValueError("Không tìm thấy hàng chứa 'Mã dịch vụ:'")
        td = row.find_next_sibling('td')
        if not td:
            raise ValueError("Không tìm thấy ô thứ hai chứa ID")

        # Lấy ID trong thẻ <a> hoặc <b> trong ô
        ids = []
        for tag in td.find_all(['a', 'b']):
            text = tag.get_text(strip=True)
            if text.isdigit():
                ids.append(int(text))
            else:
                digits = ''.join(filter(str.isdigit, text))
                if digits:
                    ids.append(int(digits))

        if not ids:
            raise ValueError("Không tìm thấy ID nào trong ô 'Mã dịch vụ:'")

        return index, link, max(ids), None
    except Exception as e:
        return index, link, None, f"Lỗi xử lý nội dung trang: {e}"

def main():
    # Tạo session giữ cookie PHPSESSID
    session = requests.Session()
    session.cookies.set('PHPSESSID', PHPSESSID_VALUE)

    # Đọc danh sách link
    try:
        with open('service_links.txt', 'r', encoding='utf-8') as f:
            links = [line.strip() for line in f if line.strip()]
    except Exception as e:
        print(f"Lỗi đọc file service_links.txt: {e}")
        return

    results = [None] * len(links)
    errors = []

    print("Bắt đầu xử lý các link...")

    with ThreadPoolExecutor(max_workers=10) as executor:
        future_map = {executor.submit(process_link, i, link, session): i for i, link in enumerate(links)}
        for future in as_completed(future_map):
            idx = future_map[future]
            try:
                i, link, id_new, err = future.result()
                if err:
                    print(f"[Lỗi] {link}: {err}")
                    errors.append(f"{link} -> {err}")
                else:
                    print(f"[OK] {link}: {id_new}")
                    results[i] = id_new
            except Exception as e:
                print(f"[Ngoại lệ] {links[idx]}: {e}")
                errors.append(f"{links[idx]} -> Ngoại lệ: {e}")

    # Ghi kết quả
    with open('new_ids.txt', 'w', encoding='utf-8') as f:
        for link, id_new in zip(links, results):
            f.write(f"{link} -> {id_new if id_new else '[Lỗi]'}\n")

    with open('error_log.txt', 'w', encoding='utf-8') as f:
        for err in errors:
            f.write(err + "\n")

    print("Hoàn tất. Kết quả trong 'new_ids.txt', lỗi trong 'error_log.txt'.")

if __name__ == "__main__":
    main()
