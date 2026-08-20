## Kiến trúc Domain Controller
```



```

## GPC và GPT
```
Group Policy Container (GPC): Là một Object nằm trong database của Active Directory (Active Directory Domain Services). Nó lưu thuộc tính, phiên bản (Version Number), danh sách OU được liên kết... Thành phần này được đồng bộ bởi AD Replication (Active Directory Engine)

Group Policy Template (GPT): Là thư mục chứa file thực tế nằm trong C:\Windows\SYSVOL\domain\Policies\{GUID_CUA_GPO}. Nó chứa file Registry.pol, các file Script .bat/.ps1... Thành phần này được đồng bộ bởi DFSR
```

## DFSR
```
0 = Uninitialized
1 = Initialized
2 = Initial Sync
3 = Auto Recovery
4 = Normal
5 = In Error

Get-CimInstance -Namespace root\MicrosoftDFS -ClassName DfsrReplicationGroupMembershipState | Select-Object State


```