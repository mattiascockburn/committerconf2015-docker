#!/bin/bash
# Yell at giese@b1-systems.de if this breaks
set -u
set -e
set -o pipefail

. ../config || {
	echo Failed to read config
	exit 1
}

MODE=${1:-create}

if [[ $LAME_INTERNET -eq 1 ]];then
    CREATE_OPTIONS="$CREATE_OPTIONS --virtualbox-boot2docker-url $B2D_URL"
fi

load_image() {
    [[ $LAME_INTERNET -ne 1 ]] && return
    dhost=${2:-none}
    image=$1
    OPTS=''

    if [[ "$dhost" != 'none' ]]; then
	OPTS=$(docker-machine config $dhost)
    fi

    docker $OPTS load -i "$IMAGEPATH"/"$image".tar
}

create_setup() {
    docker-machine create $CREATE_OPTIONS -d $DRIVER consul-test

    load_image progrium-consul consul-test
	
    docker $(docker-machine config consul-test) run -d \
	-p "8500:8500" \
	-h "consul" \
	progrium/consul -server -bootstrap

    docker-machine create \
	-d $DRIVER \
	--swarm \
	--swarm-master \
	--swarm-discovery="consul://$(docker-machine ip consul-test):8500" \
	--engine-opt="cluster-store=consul://$(docker-machine ip consul-test):8500" \
	--engine-opt="cluster-advertise=eth1:0" \
	swarm-master

    num=1
    for stage in prod test; do
    docker-machine create \
	-d $DRIVER \
	--swarm \
	--swarm-discovery="consul://$(docker-machine ip consul-test):8500" \
	--engine-opt="cluster-store=consul://$(docker-machine ip consul-test):8500" \
	--engine-opt="cluster-advertise=eth1:0" \
	--engine-label stage=$stage \
	node$num &
	num=$(( $num + 1 ))
    done
    echo Waiting for nodes to finish provisioning
    wait
}

cleanup() {
    # may fail. i don't care
    set +e
    for node in consul-test swarm-master $(seq -s ' ' -f 'node%g' 1 $NUM_INSTANCES); do
	docker-machine rm $node
    done
    set -e
}

case $MODE in
    create)
	create_setup
	;;
    cleanup)
	cleanup
	;;
    *)
	echo Fail
	exit 1
esac
