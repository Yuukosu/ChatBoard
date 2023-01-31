#!/bin/sh

sudo -v

if [ -z "$(ls | grep -E "^database$")" ] || [ -z "$(ls ./database)" ]; then
	if [ -n "$(./init.sh | grep -E "インストールされていません。$")" ]; then
		echo "データベースの初期化に失敗しました。"
		exit 0
	fi
fi

if [ -z "$(which docker)" ]; then
	echo "docker がインストールされていません。"
	exit 0
fi

if [ -z "$(which docker-compose)" ]; then
	echo "docker-compose がインストールされていません。"
	exit 0
fi

sudo chown $(whoami):$(whoami) ./database
docker-compose up --build -d
