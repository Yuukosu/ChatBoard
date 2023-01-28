#!/bin/sh
if [ -z "$(ls -d ./database)" ]; then
	mkdir database
fi

docker-compose up -d
