#!/bin/sh

if [ -z $1 ]; then
	echo "Usage: $0 [MySQL Host]"
	exit 0
fi

mysql -u root -h $1 --password=root < init.sql
