#!/bin/bash
AUTOCONFIG=0

if [ "${1}" == "-h" ]; then
	echo "Usage:"
	echo "addnode.sh USERNAME VERSION [AUTOCONFIG]"
	exit
fi

if [ "${3}" != "" ]; then
    AUTOCONFIG=1
fi

echo "{\"netnode\":{\"user\":\"${1}\",\"sub\":\"${1}\",\"version\":\"${2}\",\"autoconfig\":${AUTOCONFIG}}}" |  sudo chef-client --local-mode --runlist 'recipe[springnet::addnode]' -j /dev/stdin
