# Hướng dẫn setup môi trường code
```
Dự án được xây dựng trên
- backend python fastapi
- frontend react + vite + tailwindcss

Điều kiện 
- Cài đặt python
- Cài đặt nvm

Hướng dẫn cài đặt truy cập https://github.com/coreybutler/nvm-windows/releases
cài gói nvm-setup.exe

Setup nodejs với nvm
nvm install 22.12.0
nvm use 22.12.0
node -v
npm -v

Lệnh cài đặt và khởi chạy frontend
npm create vite@latest frontend -- --template react-ts
cd frontend
npm install
npm i -D tailwindcss @tailwindcss/vite

Sửa config vite.config.js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [react(), tailwindcss()],
})

Sửa src/index.css
@import "tailwindcss";

Kiểm tra nhanh
npm run build

Chạy dự án
npm run dev

Lệnh update
npm install -g npm@11.6.1

Lệnh cài icons
npm install react-icons --save

Lệnh cài 
npm i react react-dom react-router-dom


```
