# rAthena 一键环境（Windows）

给 [rAthenaZhCN](https://github.com/rAthena-ZhCN/rAthenaZhCN) 使用的 Windows 数据库环境：
用 Docker 跑 **MariaDB 10.11 + phpMyAdmin**，双击即可启动，首次启动会自动导入 rAthena 的表结构。

配合 rAthenaZhCN 的 `runserver.bat`，不需要手动装 MySQL、不需要手动导库。

## 一、前置要求

- Windows 10 / 11 64 位（需要开启虚拟化，Docker Desktop 会用 WSL2）
- 安装 **Docker Desktop**：<https://www.docker.com/products/docker-desktop/>
- 本机 `3306`（数据库）和 `8080`（phpMyAdmin）端口空闲

## 二、快速开始

1. 安装并启动 Docker Desktop，等右下角托盘图标变成运行状态；
2. 下载本仓库（`Code` → `Download ZIP`）并解压，或 `git clone`；
3. 双击 **`01-启动环境.bat`**
   - 第一次启动会自动创建数据库、导入表结构，大约 30~90 秒；
   - 脚本会等到数据库真正可连接后才提示“完成”；
4. 准备 rAthenaZhCN（编译好或下载发布包），确认它的 `conf/import` 是默认配置（见第四节）；
5. 双击 rAthenaZhCN 目录下的 **`runserver.bat`**，四个服务就会连上这个数据库启动。

## 三、默认信息

| 项目 | 值 |
| --- | --- |
| 数据库地址 | `127.0.0.1:3306` |
| root 账号 | `root` / `root` |
| 游戏库账号 | `ragnarok` / `ragnarok` |
| 主库 | `ragnarok` |
| 日志库 | `ragnarok_log` |
| phpMyAdmin | <http://localhost:8080> |

这些值都可以用同目录的 `.env` 覆盖（复制 `.env.example` 为 `.env` 再改）。

## 四、和服务端的配置对应

rAthenaZhCN 仓库里已经带好默认的 `conf/import`：

```
conf/import/inter_conf.txt   -> 数据库 ragnarok / ragnarok_log，账号 ragnarok/ragnarok
conf/import/char_conf.txt    -> 127.0.0.1
conf/import/map_conf.txt     -> 127.0.0.1
```

如果你在 `.env` 里改了端口、密码或库名，需要同步修改 `conf/import/inter_conf.txt`（以及 `initdb` 里的库名）。

## 五、目录说明

```
rAthena-env-win/
├── docker-compose.yml     MariaDB + phpMyAdmin 定义
├── initdb/                首次启动自动执行的 SQL
│   ├── 00-databases.sql   创建 ragnarok / ragnarok_log
│   ├── 10-main.sql        rAthena 主表结构
│   ├── 20-logs.sql        日志表结构
│   └── 30-roulette.sql    转盘默认数据
├── 01-启动环境.bat        启动（推荐日常使用）
├── 02-关闭环境.bat        停止容器（数据保留）
├── 03-查看状态.bat        查看容器/数据库状态
├── 09-重置数据库.bat      删除数据卷并重新初始化（危险）
├── .env.example           可选配置
└── LICENSE                GPLv3（SQL 来自 rAthena）
```

数据库文件保存在 Docker 命名卷 `rathena_mysql_data` 里，不会进入仓库目录，也不会被 Git 跟踪。

## 六、关闭、重置与备份

- **关闭**：双击 `02-关闭环境.bat`（数据保留）
- **重置**：双击 `09-重置数据库.bat`，输入 `YES` 确认（删除所有游戏数据后重新初始化）
- **备份**：

```bat
docker exec rathena_db mysqldump -uroot -proot --databases ragnarok ragnarok_log > backup.sql
```

- **恢复**：

```bat
docker exec -i rathena_db mysql -uroot -proot < backup.sql
```

## 七、表结构版本

`initdb/` 里的 SQL 来自 rAthenaZhCN 的 `sql-files`（2026-10 快照）。rAthena 升级后如果表结构有变化：

- 全新安装：`09-重置数据库.bat` 重新初始化即可；
- 保留数据升级：按 rAthenaZhCN `sql-files/upgrades/` 里的升级脚本手动执行；
- 想同步最新结构：把 rAthenaZhCN `sql-files/main.sql` 覆盖到 `initdb/10-main.sql`，`logs.sql` 覆盖到 `initdb/20-logs.sql` 并保留文件开头的 `USE ragnarok_log;`。

## 八、常见问题

**1. 提示找不到 docker 命令**
没装 Docker Desktop，或安装后没重启终端。

**2. 提示 Docker Desktop 没有运行**
先启动 Docker Desktop，等托盘图标变成运行状态再双击脚本。

**3. 3306 端口被占用**
可能本机已装 MySQL/MariaDB。要么停掉本机服务，要么在 `.env` 里改 `DB_PORT=3307`，并同步修改 rAthenaZhCN 的 `conf/import/inter_conf.txt` 里的 `login_server_port` / `char_server_port` / `map_server_port`。

**4. 首次初始化失败**
看日志：`docker logs rathena_db`。修复后执行 `09-重置数据库.bat`（会重新导入）。

**5. 数据存在哪？换电脑怎么办**
在 Docker 命名卷里。换电脑用第六节的 `mysqldump` 备份/恢复。

**6. 能不能不用 Windows？**
`docker compose up -d` 在 macOS/Linux 上同样可用，只是 `.bat` 脚本需要换成对应的 shell 命令。

## 九、许可

- 数据库表结构 SQL 来自 [rAthena](https://github.com/rathena/rathena)，GPLv3；
- 本仓库的脚本与文档同样以 GPLv3 发布，见 `LICENSE`。
