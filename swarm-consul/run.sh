#!/bin/bash
set -u
set -e
set -o pipefail

. ../config || {
	echo Failed to read config
	exit 1
}

MODE=${1:-create}

create_setup() {
    docker-machine create -d $DRIVER consul-test

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
	master

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

    for node in consul-test master; do
	docker-machine rm $node
    done
    for a in $(seq 1 $NUM_INSTANCES); do
	docker-machine rm node$a
    done
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
