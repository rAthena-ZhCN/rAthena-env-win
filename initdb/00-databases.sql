-- rAthena 需要的主库和日志库
-- 主库由 docker-compose 的 MYSQL_DATABASE 创建，这里补齐日志库和授权。
CREATE DATABASE IF NOT EXISTS `ragnarok` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ragnarok_log` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

GRANT ALL PRIVILEGES ON `ragnarok`.* TO 'ragnarok'@'%';
GRANT ALL PRIVILEGES ON `ragnarok_log`.* TO 'ragnarok'@'%';
FLUSH PRIVILEGES;
