#!/bin/sh

sudo -v

if [ -n "$(docker-compose ps | grep -E "^app")" ]; then
	docker-compose down
fi

sudo rm -rf ./database
