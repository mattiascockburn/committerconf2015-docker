# committerconf2015-docker
Files used in the presentation i gave at Committerconf 2015

You need at least docker-machine 0.5.0, docker-compose 1.5.0 and docker 1.9.0

## Stand up a cluster of machines

```
$ cd swarm-consul
$ bash run.sh
```

This script will create a host which runs consul, a swarm-master and some nodes.
The behaviour may be controlled by ./config

Demos may be found in the compose directory. Please use 'cc' as a project name:

```
$ cd compose/webapp-db
$ docker-compose -d -p cc --x-networking up
```

Some examples are shamelessly ripped^W^Winspired from the Docker-Docs (with some modifications).

Have Fun!
