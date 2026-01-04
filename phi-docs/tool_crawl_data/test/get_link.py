import requests
from bs4 import BeautifulSoup
import concurrent.futures
import re
import time
from urllib.parse import urljoin
import urllib3
from urllib3.exceptions import InsecureRequestWarning


urllib3.disable_warnings(InsecureRequestWarning)
# Cấu hình session và headers
session = requests.Session()
session.headers.update({
    'Host': 'admin.hostingviet.vn',
    'Sec-Ch-Ua': '"Chromium";v="137", "Not/A)Brand";v="24"',
    'Sec-Ch-Ua-Mobile': '?0',
    'Sec-Ch-Ua-Platform': '"Linux"',
    'Accept-Language': 'en-US,en;q=0.9',
    'Upgrade-Insecure-Requests': '1',
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'Sec-Fetch-Site': 'same-origin',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-User': '?1',
    'Sec-Fetch-Dest': 'document',
    'Referer': 'https://admin.hostingviet.vn/?hdl=index',
    'Priority': 'u=0, i',
    'Cookie': 'PHPSESSID=nsgk8m7n6pposvaeoqp9o5003e'
})

def fetch_service_link(service_id):
    """Lấy link dịch vụ từ ID cho trước"""
    params = {
        'hdl': 'service/list',
        'search_inactive_service': '',
        'start_date_search': '',
        'end_date_search': '',
        'emp_service_owner': '',
        'money_status_detail': '',
        'no_search_time': '1',
        'filter[username]': service_id,
        'frmtoken': '8075e2c38ef8cd3fba1fdcb3b448b50a8d97527db4abb0b18e6f1e33e0b69988'
    }
    
    try:
        response = session.get(
            'https://admin.hostingviet.vn/',
            verify=False,
            params=params,
            timeout=30
        )
        response.raise_for_status()
        
        # Phân tích HTML để tìm link
        soup = BeautifulSoup(response.text, 'html.parser')
        service_link = soup.find('a', href=re.compile(r'hdl=service/view&service_id='))
        
        if service_link:
            # Tạo URL tuyệt đối
            return urljoin('https://admin.hostingviet.vn/', service_link['href'])
        else:
            print(f"⚠️ Không tìm thấy link cho ID: {service_id}")
            return None
            
    except Exception as e:
        print(f"🚨 Lỗi khi xử lý ID {service_id}: {str(e)}")
        return None

def main():
    # Đọc danh sách ID từ file
    with open('ids.txt', 'r') as f:
        service_ids = [line.strip() for line in f if line.strip()]
    
    print(f"🔍 Tìm thấy {len(service_ids)} ID cần xử lý")
    
    # Sử dụng ThreadPool để xử lý song song
    results = [None] * len(service_ids)  # Giữ nguyên thứ tự
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        future_to_index = {
            executor.submit(fetch_service_link, sid): idx 
            for idx, sid in enumerate(service_ids)
        }
        
        for future in concurrent.futures.as_completed(future_to_index):
            idx = future_to_index[future]
            try:
                results[idx] = future.result()
            except Exception as e:
                print(f"❌ Lỗi không xác định: {str(e)}")
                results[idx] = None
    
    # Lưu kết quả vào file
    with open('service_links.txt', 'w') as f:
        for link in results:
            if link:
                f.write(link + '\n')
    
    print(f"✅ Đã hoàn thành! Kết quả lưu vào service_links.txt")

if __name__ == '__main__':
    start_time = time.time()
    main()
    print(f"⏱️ Thời gian thực thi: {time.time() - start_time:.2f} giây")
