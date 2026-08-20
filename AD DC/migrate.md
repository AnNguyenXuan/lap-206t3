## Demote AD 
```
Quy trình Demote AD chia làm 2 phase
Phase 1 : Demote tại AD cần thao tác
Bước 1. Truy cập vào AD-01-VITM
Bước 2. Mở Server Manage →  Remove Role and Features
Bước 3. Tại pop-up
  + Bảng Befor You Begin: Chọn Next
  + Bảng Server Selection: Chọn AD-01-VITM → Next
  + Bảng Role: Untick mục Active Directory Domain Services → Chọn Add Features tại pop-up
Bước 4. Sau khi chọn Remove Features pop-up Validation Results hiển thị → Chọn Demote this domain controller.
Bước 5. Tại bảng Credentials:
+ Chọn Next
+ Bảng warning:: Tick Proceed with removal → Chọn Next (Không tích Force the removal of this domain)
+ Bảng Removal Options: Chọn Remove DNS delegation → Chọn Next
+ Bảng New Administrator Password: Nhập pass mới
+ Review Options: Chọn Demote

Phase 2 : Xóa Metadata còn xót lại trên các AD còn lại

```