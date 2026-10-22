@echo off
title Khoi chay dong thoi App & Web Admin
echo ===================================================
echo [3] DANG KHOI CHAY DONG THOI CA 2:
echo   - Mobile App : http://localhost:3000
echo   - Web Admin  : http://localhost:4000
echo ===================================================
start "Mobile App (Port 3000)" cmd /k "flutter run -t lib/main.dart -d chrome --web-port 3000"
timeout /t 3 /nobreak >nul
start "Web Admin (Port 4000)" cmd /k "flutter run -t lib/main_admin.dart -d chrome --web-port 4000"
