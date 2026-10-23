@echo off
chcp 936 >nul
setlocal
cd /d "%~dp0"
echo === 容器状态 ===
docker compose ps
echo.
echo === 数据库连通性 ===
docker exec rathena_db mysqladmin ping -h 127.0.0.1 -uroot -proot 2>nul
if errorlevel 1 (
    echo 数据库未就绪或未启动
) else (
    echo 数据库正常
)
echo.
echo === ragnarok 库表数量 ===
docker exec rathena_db mysql -uroot -proot -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='ragnarok';" 2>nul
echo.
pause
