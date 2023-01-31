#!/bin/sh
ip="0.0.0.0"

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	echo "Usage: $0 [MySQL Host]"
	exit 0
fi

if [ -z "which docker" ]; then
	echo "Docker がインストールされていません。"
	exit 0
fi

if [ -z "which docker-compose" ]; then
	echo "Docker-Compose がインストールされていません。"
	exit 0
fi

if [ -z "which mysql" ]; then
	echo "MySQL がインストールされていません。"
	exit 0
fi

if [ -n "$1" ]; then
	if [ "$1" = "auto" ]; then
		ip=$(docker inspect app_database | grep -E "\"IPAddress\": \"[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}\"" | sed -e 's/\"//g' -e 's/ //g' -e 's/IPAddress://g' -e 's/,//g')

		if [ -z "$ip" ]; then
			echo "IPの取得に失敗しました。"
			exit 0
		fi
	elif [ -n "$(echo "$1" | grep -E "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$")" ]; then
		ip=$1
	else
		echo "無効な引数です。"
		exit 0
	fi
fi

if [ -z "$(docker-compose ps | grep ^app_database)" ]; then
	echo "Starting database container..."
	
	if [ -z "ls | grep ^database$" ]; then
		mkdir database
	fi

	docker-compose up -d db
	sleep 10
fi

echo "Database Initializing..."

cat > /tmp/init.sql << EOF
CREATE DATABASE IF NOT EXISTS app;
USE app;
CREATE TABLE IF NOT EXISTS thread (id TEXT, json LONGTEXT);
EOF

mysql -u root -h $ip --password=root < /tmp/init.sql
rm -f /tmp/init.sql
docker-compose down
