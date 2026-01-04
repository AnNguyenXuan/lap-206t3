#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import pandas as pd
from bs4 import BeautifulSoup

def parse_table_from_html(html_content):
    """
    Nhận vào nội dung HTML, trả về list of dict chứa dữ liệu bảng.
    Trả về None nếu không tìm thấy bảng.
    """
    soup = BeautifulSoup(html_content, 'lxml')
    table = soup.find('table', class_='data-table')
    if table is None:
        return None

    # Lấy header
    headers = []
    header_row = table.find('tr', class_='data-table-header')
    if not header_row:
        return None
        
    header_cells = header_row.find_all('td')
    for cell in header_cells:
        headers.append(cell.get_text(strip=True))

    # Lấy các hàng data
    data = []
    for row in table.find_all('tr')[1:]:
        cells = row.find_all('td')
        if len(cells) != len(headers):
            continue
        values = [cell.get_text(strip=True) for cell in cells]
        data.append(dict(zip(headers, values)))
        
    return data

def get_ordered_uids(uid_file='hehe.txt'):
    """Đọc và trả về danh sách UID theo đúng thứ tự trong file"""
    with open(uid_file, 'r') as f:
        return [line.strip() for line in f if line.strip()]

def process_all_html_files(input_folder, output_csv, uid_file='hehe.txt'):
    """
    Duyệt file .html theo thứ tự UID trong uid_file, 
    đảm bảo mỗi UID có ít nhất 1 dòng trong CSV
    """
    ordered_uids = get_ordered_uids(uid_file)
    all_records = []
    
    for uid in ordered_uids:
        filepath = os.path.join(input_folder, f"{uid}.html")
        record_base = {
            '_source_uid': uid,
            '_source_file': f"{uid}.html",
            '_data_status': 'FOUND'  # Mặc định là có dữ liệu
        }
        
        # Tạo bản ghi mặc định cho UID
        default_record = record_base.copy()
        default_record['_data_status'] = 'MISSING'
        
        if not os.path.exists(filepath):
            all_records.append(default_record)
            print(f"⚠️ File không tồn tại: {uid}.html - Tạo bản ghi trống")
            continue
            
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                html = f.read()
                
            records = parse_table_from_html(html)
            
            if records is None:
                # Không tìm thấy bảng
                all_records.append(default_record)
                print(f"⚠️ Không tìm thấy bảng trong: {uid}.html - Tạo bản ghi trống")
                continue
                
            if len(records) == 0:
                # Bảng tồn tại nhưng không có dữ liệu
                all_records.append(default_record)
                print(f"⚠️ Bảng rỗng trong: {uid}.html - Tạo bản ghi trống")
                continue
                
            # Thêm thông tin UID vào mỗi record
            for r in records:
                r.update(record_base)
                
            all_records.extend(records)
            print(f"✅ Đã xử lý: {uid}.html - {len(records)} bản ghi")
            
        except Exception as e:
            print(f"❌ Lỗi khi xử lý {uid}.html: {str(e)} - Tạo bản ghi trống")
            all_records.append(default_record)

    # Tạo DataFrame từ tất cả bản ghi
    df = pd.DataFrame(all_records)
    
    # Sắp xếp lại theo thứ tự UID gốc
    df['_order'] = df['_source_uid'].apply(lambda x: ordered_uids.index(x))
    df = df.sort_values('_order').drop('_order', axis=1)
    
    # Đảm bảo các UID không có dữ liệu vẫn có dòng
    missing_uids = set(ordered_uids) - set(df['_source_uid'])
    for uid in missing_uids:
        df = pd.concat([
            df, 
            pd.DataFrame([{
                '_source_uid': uid,
                '_source_file': f"{uid}.html",
                '_data_status': 'MISSING'
            }])
        ], ignore_index=True)
    
    # Sắp xếp lại lần cuối
    df['_order'] = df['_source_uid'].apply(lambda x: ordered_uids.index(x))
    df = df.sort_values('_order').drop('_order', axis=1)
    
    df.to_csv(output_csv, index=False, encoding='utf-8-sig')
    print(f"\n✅ Đã xuất {len(df)} bản ghi ra {output_csv}")
    print(f"• {len(df[df['_data_status'] == 'FOUND'])} UID có dữ liệu")
    print(f"• {len(df[df['_data_status'] == 'MISSING'])} UID không có dữ liệu")
    print(f"• {len(ordered_uids)} UID trong danh sách gốc")

if __name__ == '__main__':
    # Cấu hình
    INPUT_FOLDER = 'responses'
    OUTPUT_CSV = 'output.csv'
    UID_FILE = 'hehe.txt'
    
    if not os.path.isfile(UID_FILE):
        print(f"⛔ File UID không tồn tại: {UID_FILE}")
        exit(1)
        
    if not os.path.isdir(INPUT_FOLDER):
        print(f"⛔ Thư mục không tồn tại: {INPUT_FOLDER}")
        exit(1)
        
    process_all_html_files(INPUT_FOLDER, OUTPUT_CSV, UID_FILE)
