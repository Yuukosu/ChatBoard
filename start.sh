#!/bin/sh

sudo -v

if [ -z "$(ls -d ./database)" ]; then
	mkdir database
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
