#!/bin/bash

# 설정 변수
NAMESPACE="database"
POD_NAME="mariadb-galera-0"
CONTAINER_NAME="mariadb"
ROOT_PW="root1234!"

echo "🔄 MariaDB Galera Cluster 초기화를 시작합니다..."

INIT_SQL=$(cat <<EOF
-- Nextcloud 초기화
DROP DATABASE IF EXISTS nextcloud_db;
CREATE DATABASE nextcloud_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'next_admin'@'%' IDENTIFIED BY 'next_pass';
GRANT ALL PRIVILEGES ON nextcloud_db.* TO 'next_admin'@'%';

-- WordPress 초기화
DROP DATABASE IF EXISTS wordpress_db;
CREATE DATABASE wordpress_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'wp_admin'@'%' IDENTIFIED BY 'wp_pass';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wp_admin'@'%';

-- MediaWiki 초기화
DROP DATABASE IF EXISTS mediawiki_db;
CREATE DATABASE mediawiki_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'wiki_admin'@'%' IDENTIFIED BY 'wiki_pass';
GRANT ALL PRIVILEGES ON mediawiki_db.* TO 'wiki_admin'@'%';

-- Grafana 초기화
DROP DATABASE IF EXISTS grafana_db;
CREATE DATABASE grafana_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'gf_admin'@'%' IDENTIFIED BY 'gf_pass';
GRANT ALL PRIVILEGES ON grafana_db.* TO 'gf_admin'@'%';

FLUSH PRIVILEGES;
EOF
)

# 2. MariaDB 명령 실행
echo "🚀 SQL 명령을 $POD_NAME 에 전송 중..."
echo "$INIT_SQL" | kubectl exec -i $POD_NAME -n $NAMESPACE -c $CONTAINER_NAME -- mariadb -u root -p"$ROOT_PW"

if [ $? -eq 0 ]; then
    echo "✅ 모든 데이터베이스가 성공적으로 초기화되었습니다!"
else
    echo "❌ 초기화 중 오류가 발생했습니다."
fi
