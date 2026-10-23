@echo off
chcp 936 >nul
setlocal
cd /d "%~dp0"
echo ==========================================
echo   rAthena 一键环境（Windows + Docker）
echo ==========================================
echo.

where docker >nul 2>nul
if errorlevel 1 (
    echo [错误] 没有找到 docker 命令。
    echo        请先安装 Docker Desktop：https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

docker info >nul 2>nul
if errorlevel 1 (
    echo [错误] Docker Desktop 没有运行。
    echo        请先启动 Docker Desktop，等右下角托盘图标变为运行状态后再试。
    pause
    exit /b 1
)

echo [1/3] 启动 MariaDB / phpMyAdmin ...
docker compose up -d
if errorlevel 1 (
    echo [错误] docker compose 启动失败，请查看上面的输出。
    pause
    exit /b 1
)

echo [2/3] 等待数据库就绪（首次启动会自动导入表结构，约 30-90 秒）...
set /a n=0
:waitdb
docker exec rathena_db mysqladmin ping -h 127.0.0.1 -uroot -proot --silent >nul 2>nul
if not errorlevel 1 goto dbready
set /a n+=1
if %n% geq 90 goto dbtimeout
timeout /t 2 /nobreak >nul
goto waitdb

:dbtimeout
echo [错误] 等待数据库超时。
echo        请运行 03-查看状态.bat 查看容器状态和日志。
pause
exit /b 1

:dbready
echo [3/3] 检查数据表 ...
docker exec rathena_db mysql -uroot -proot -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='ragnarok';" > "%TEMP%\rathena_tables.txt" 2>nul
set /p TABLES=<"%TEMP%\rathena_tables.txt"
del "%TEMP%\rathena_tables.txt" >nul 2>nul
echo.
echo [完成] 环境已就绪！当前 ragnarok 库有 %TABLES% 张表。
echo.
echo   MariaDB     127.0.0.1:3306
echo   账号        root / root
echo   数据库      ragnarok 和 ragnarok_log
echo   phpMyAdmin  http://localhost:8080
echo.
echo 下一步：进入 rAthenaZhCN 目录，双击 runserver.bat 启动服务器。
echo.
pause
