#!/bin/bash
if [ "${1}" = "-h" ]; then
	echo "Usage:"
	echo "remnode.sh USERNAME"
	exit
fi

if [ "${1}" == "" ]; then
	echo "Usage:"
	echo "remnode.sh USERNAME"
	exit
fi

echo "{\"netnode\":{\"user\":\"${1}\",\"sub\":\"${1}\"}}" |  sudo chef-client --local-mode --runlist 'recipe[springnet::remnode]' -j /dev/stdin
