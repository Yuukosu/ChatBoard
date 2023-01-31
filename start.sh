#!/bin/sh

sudo -v

if [ -z "$(ls | grep -E "^database$")" ] || [ -z "$(ls ./database)" ]; then
	./init.sh
fi

if [ -z "$(which docker-compose)" ]; then
	echo "docker-compose がインストールされていません。"
	exit 0
elif [ -z "$(which docker)" ]; then
	echo "docker がインストールされていません。"
	exit 0
fi

sudo chown $(whoami):$(whoami) -R ./database
docker-compose up --build -d
