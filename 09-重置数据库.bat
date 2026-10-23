@echo off
chcp 936 >nul
setlocal
cd /d "%~dp0"
echo ==========================================
echo   重置数据库（会删除所有游戏数据！）
echo ==========================================
echo.
echo 将删除 Docker 数据卷 rathena_mysql_data
echo.
set /p CONFIRM=确认请输入 YES 后回车：
if /i not "%CONFIRM%"=="YES" (
    echo 已取消。
    pause
    exit /b 0
)
docker compose down -v
echo 数据已删除，正在重新初始化 ...
docker compose up -d
echo.
echo 完成。首次初始化需要 30-90 秒，请用 03-查看状态.bat 确认。
pause
