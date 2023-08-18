#!/usr/bin/env bash

dcnuke(){
    docker system prune -a --volumes
}

dccs(){
    local name=$1
	local state
	state=$(docker inspect --format "{{.State.Running}}" "$name" 2>/dev/null)

	if [[ "$state" == "false" ]]; then
		docker rm "$name"
	fi
}
