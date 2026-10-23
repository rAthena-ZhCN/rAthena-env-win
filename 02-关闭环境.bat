@echo off
chcp 936 >nul
setlocal
cd /d "%~dp0"
echo 正在停止 rAthena 环境（数据库文件会保留）...
docker compose down
echo.
echo 已停止。下次启动请双击 01-启动环境.bat。
pause
